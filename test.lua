-- Chờ game -> người dùng -> kho đồ 
repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer.Character
repeat wait() until game.Players.LocalPlayer.Backpack
-- game.Players.LocalPlayer.PlayerGui.Main.DragonSelection.Root.DragonSelectionMenu.Enabled = false

-- Dữ liệu có sẵn
local Sea = { -- sea ids
    [4442272183] = 2, -- Sea 2
    [7449423635] = 3, -- Sea 3
    [2753915549] = 0  -- Current sea
}

-- Định dạng luồng dữ liệu
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------
--- [ = = = = = = = \ MAIN / = = = = = = = ]
--------------------------------------------

function fetchPlayerData()
    local data = {
        Name       = LocalPlayer.Name,
        Level      = LocalPlayer.Data.Level.Value,
        Bounty     = LocalPlayer.leaderstats["Bounty/Honor"].Value,
        DevilFruit = LocalPlayer.Data.DevilFruit.Value,
        Race       = LocalPlayer.Data.Race.Value,
        Fragments  = LocalPlayer.Data.Fragments.Value,
        Beli       = LocalPlayer.Data.Beli.Value,
        Valor      = LocalPlayer.Data.Valor.Value,
        FruitCap   = LocalPlayer.Data.FruitCap.Value
    }

    -- Lấy kho đồ
    ReplicatedStorage.Remotes.SubclassNetwork.GetPlayerData:InvokeServer()
    ReplicatedStorage.Remotes.GetFruitData:InvokeServer()
    local Fruit = ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits", false)
    local Inventory = ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")

    -- Kiểm tra trạng thái Race
    local RaceAwakenValue = 1
    if ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Check") == 4 then
        RaceAwakenValue = 4
    elseif ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1") == -2 then
        RaceAwakenValue = 3
    elseif ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist") == -2 then
        RaceAwakenValue = 2
    end
    data.RaceAwakenValue = RaceAwakenValue

    -- EliteHunter và SpyStatus
    local EliteHunterProcess = ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
    local SpyStatus = ReplicatedStorage.Remotes.CommF_:InvokeServer("InfoLeviathan", 1)
    
    if Sea[game.PlaceId] ~= 3 then
        data.EliteHunterProcess = "Không tìm thấy"
        data.SpyText = "Không tìm thấy"
    else
        data.EliteHunterProcess = "Total Killed Elite Hunter: " .. EliteHunterProcess
        data.SpyText = SpyStatus == -1 and "Spy: Still in Cooldown" or "Spy: Found Leviathan"
    end

    -- Lấy vũ khí
    local function updateWeapon(container, weaponData)
        for _, v in pairs(container:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Level") then
                weaponData[v.ToolTip] = { Name = v.Name, Level = v.Level.Value }
            end
        end
    end

    data.Weapons = {}
    updateWeapon(LocalPlayer.Backpack, data.Weapons)
    updateWeapon(LocalPlayer.Character, data.Weapons)

    return data
end

print(fetchPlayerData())
