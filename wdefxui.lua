下面这个代码，你看一下哪个是修改枪的射￼￼￼速￼的￼
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function ModifyWeaponStats()
    local garbage = getgc(true)
    for _, tbl in pairs(garbage) do
        if type(tbl) == "table" then
            if rawget(tbl, "SHOOT_MODE") then
                rawset(tbl, "SHOOT_MODE", 2)
            end
            if rawget(tbl, "RPM") then
                rawset(tbl, "RPM", math.huge)
            end
            if rawget(tbl, "DAMAGE") then
                rawset(tbl, "DAMAGE", math.huge)
            end
        end
    end
    print("1")
end

local function SetupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
 
    humanoid.Died:Connect(ModifyWeaponStats)
end

if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)

task.wait(0.2)
ModifyWeaponStats()