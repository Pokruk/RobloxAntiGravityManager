# RobloxAntiGravityManager
Usefull roblox service-like ModuleScript to help disable gravity for models or parts

Example:
Disabling gravity for every player
```lua
local Players = game:GetService("Players")

local AntiGravityManager = require(path.to.module)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		AntiGravityManager:disableGrav(character)
	end)
end)
```
