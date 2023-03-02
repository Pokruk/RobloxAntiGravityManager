function getMass(model)
	local mass = 0
	for i, v in pairs(model:GetChildren()) do
		if v:IsA('BasePart') or v:IsA('Union') then
			mass = mass + v:GetMass()
		end
	end
	return mass
end

local AntiGravityManager = {}
function AntiGravityManager:new()
	local this = {}

	this.ATTACHMENT_NAME = "noGravAttachment"
	this.VECTOR_FORCE_NAME = "noGravForce"

	this.connects = {}

	function this:_getPartToApplyForce(partOrModel: Model | Part)
		local partToApply = nil
		if partOrModel:IsA("Model") then
			partToApply = partOrModel.PrimaryPart
		elseif partOrModel:IsA("Part") then
			partToApply = partOrModel
		else
			error("should be Model or Part")
		end
		return partToApply
	end

	function this:isDisabledGravity(partOrModel: Model | Part)
		local partToApply = this:_getPartToApplyForce(partOrModel)

		return partToApply:FindFirstChild(this.ATTACHMENT_NAME) ~= nil or partToApply:FindFirstChild(this.VECTOR_FORCE_NAME) ~= nil
	end

	function this:disableGrav(partOrModel: Model | Part)
		local partToApply = this:_getPartToApplyForce(partOrModel)
		if this:isDisabledGravity(partOrModel) then
			error("already disabled gravity")
		end

		local attachment = Instance.new("Attachment", partToApply)
		attachment.Name = this.ATTACHMENT_NAME
		local vectorForce = Instance.new("VectorForce", partToApply)
		vectorForce.Name = this.VECTOR_FORCE_NAME
		vectorForce.Attachment0 = attachment

		vectorForce.ApplyAtCenterOfMass = true
		vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World

		local function updateForce()
			print("upd force")
			local mass = partToApply.AssemblyMass
			if partOrModel:IsA("Model") then
				local model: Model = partOrModel
				mass = getMass(model)
			end
			vectorForce.Force = Vector3.new(0, mass * workspace.Gravity,0)
		end
		updateForce()

		this.connects[partToApply] = {}
		table.insert(
			this.connects[partToApply],
			workspace:GetPropertyChangedSignal("Gravity"):Connect(updateForce)
		)
		table.insert(
			this.connects[partToApply],
			partToApply:GetPropertyChangedSignal("AssemblyMass"):Connect(updateForce)
		)
		table.insert(
			this.connects[partToApply],
			partToApply:GetPropertyChangedSignal("CustomPhysicalProperties"):Connect(updateForce)
		)
	end

	function this:enableGrav(partOrModel: Model | Part)
		if not this:isDisabledGravity(partOrModel) then
			error("already enabled gravity")
		end
		partOrModel[this.ATTACHMENT_NAME]:Destroy()
		partOrModel[this.VECTOR_FORCE_NAME]:Destroy()
		for _, connect in ipairs(this.connects[partOrModel]) do
			connect:Disconnect()
		end
		this.connects[partOrModel] = nil

	end

	return this
end

return AntiGravityManager:new()