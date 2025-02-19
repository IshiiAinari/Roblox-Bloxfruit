-- Chờ game -> người dùng -> kho đồ 
repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer.Character
repeat wait() until game.Players.LocalPlayer.Backpack
--game.Players.LocalPlayer.PlayerGui.Main.DragonSelection.Root.DragonSelectionMenu.Enabled = false

-- Dữ liệu có sẵn
local Sea = { -- sea ids
    [4442272183] = 2, -- Sea 2
    [7449423635] = 3, -- Sea 3
    [2753915549] = 0  -- Current sea
}

DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1329859604053622848/VY_e5SO-xJRp0kGaf8xn9IA0kHuWEvqe27vxmxDiIxfpUQiGnE_tBmJ4trRFggszgOdL"
AUTO_EXECUTE_CONFIG = {
    Enabled = true,
    Interval = 3600,
    NotifyThreshold = 1.3
}

-- Định dạng luồng dữ liệu
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
-- local HttpService = game:GetService("HttpService")
-- local LocalPlayer = Players.LocalPlayer

--------------------------------------------
--- [ = = = = = = = \ MAIN / = = = = = = = ]
--------------------------------------------

function fetchPlayerData()
    local data = {
        Name = Player.Name,
        Level = Player.Data.Level.Value,
        Bounty = Player.leaderstats["Bounty/Honor"].Value,
        DevilFruit = Player.Data.DevilFruit.Value,
        Race = Player.Data.Race.Value,
        Fragments = Player.Data.Fragments.Value,
        Beli = Player.Data.Beli.Value,
        Valor = Player.Data.Valor.Value,
        FruitCap = Player.Data.FruitCap.Value
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
    updateWeapon(Player.Backpack, data.Weapons)
    updateWeapon(Player.Character, data.Weapons)

    return data
end

-------------
--Paste Player Data
function fetchPlayerData()
    local data = {
        FruitTable = {},
        PlayerFruitData = {},
        InventoryData = {},
        PrintMelee = "",
    }

    -- Lấy danh sách vũ khí cận chiến
    local NameMelee = {"BlackLeg","Electro","FishmanKarate","DragonClaw","Superhuman","DeathStep","SharkmanKarate","ElectricClaw","DragonTalon","Godhuman","SanguineArt"}
    for _, v in pairs(NameMelee) do
        local result
        if v == "DragonClaw" then
            result = ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
        else
            result = ReplicatedStorage.Remotes.CommF_:InvokeServer("Buy" .. v, true)
        end
        if result == 1 or result == 2 then
            data.PrintMelee = data.PrintMelee .. v .. ", "
        end
    end

    -- Xử lý tên vũ khí cận chiến (tách CamelCase)
    local function splitCamelCase(str)
        return str:gsub("([a-z])([A-Z])", "%1 %2")
    end

    local formattedMelee = {}
    for word in data.PrintMelee:gmatch("%S+") do
        table.insert(formattedMelee, splitCamelCase(word))
    end
    data.PrintMelee = table.concat(formattedMelee, " ")

    -- Lấy danh sách trái ác quỷ từ kho
    for _, v in pairs(Fruit) do
        for key, value in pairs(v) do
            if key == "Name" or key == "Rarity" then
                if value ~= "Dragon-Dragon" then
                    table.insert(data.FruitTable, value)
                else
                    table.insert(data.FruitTable, "Dragon (West)-Dragon (West)")
                    table.insert(data.FruitTable, 4)
                    table.insert(data.FruitTable, "Dragon (East)-Dragon (East)")
                    table.insert(data.FruitTable, 4)
                end
            end
        end
    end

    -- Lấy danh sách trái có trong kho người chơi
    for _, v in pairs(Inventory) do
        if table.find(data.FruitTable, v.Name) then
            table.insert(data.PlayerFruitData, v)
        end
    end

    -- Lưu dữ liệu vật phẩm từ kho
    data.InventoryData = Inventory

    return data
end

function generatePrintTable(data)
    local PrintTable = string.format("Player Name: %s, Level: %d, Bounty: %d, Race: %s [V%d], Fragments: %d, Beli: %d, Valor Level: %d, Fruit Capacity: %d | CurrentMelee: %s, Mastery: %d | CurrentBloxFruit: %s, Mastery: %d | CurrentSword: %s, Mastery: %d | CurrentGun: %s, Mastery: %d | Melee: %s | ",
        Name, Level, Bounty, Race, RaceAwakenValue, Fragments, Beli, Valor, FruitCap, PlayerCurrentMelee, PlayerCurrentMeleeLevel,
        PlayerCurrentFruit, PlayerCurrentFruitLevel, PlayerCurrentSword, PlayerCurrentSwordLevel, PlayerCurrentGun, PlayerCurrentGunLevel, data.PrintMelee
    )

    -- In thông tin trái ác quỷ
    for i, v in ipairs(data.FruitTable) do
        if type(v) == "string" then
            local hasFruit = table.find(data.PlayerFruitData, v)
            PrintTable = PrintTable .. string.format("Fruit Name: %s, ", v)
            if hasFruit then
                for _, fruit in pairs(data.PlayerFruitData) do
                    if fruit.Name == v then
                        for key, value in pairs(fruit) do
                            if not ({AwakeningData=true, Equipped=true, MasteryRequirements=true, Type=true, Name=true, Value=true})[key] then
                                PrintTable = PrintTable .. string.format("%s: %s, ", key, value)
                            end
                        end
                    end
                end
            else
                PrintTable = PrintTable .. string.format("Rarity: %d, Count: 0, Mastery: - | ", data.FruitTable[i+1] or 0)
            end
        end
    end

    -- In thông tin vật phẩm theo từng loại
    local itemTypes = {
        Sword = "Sword",
        Gun = "Gun",
        Wear = "Accessory",
        Material = "Material",
        Premium = "Premium"
    }

    for _, v in pairs(data.InventoryData) do
        local itemType = itemTypes[v.Type]
        if itemType then
            for key, value in pairs(v) do
                if not ({Rarity=true, MasteryRequirements=true, Scrolls=true, Equipped=true, Type=true, Value=true, Texture=true})[key] then
                    PrintTable = PrintTable .. string.format("%s %s: %s, ", itemType, key, value)
                end
            end
        end
    end

    return PrintTable
end

function pasteDataToSend()
    local success, result = pcall(function()
        local playerData = fetchPlayerData()
        return generatePrintTable(playerData)
    end)

    if success then
        print(result)
    else
        print("Error fetching data:", result)
    end
end
---------------------

---Function Misc
function FPS_BOOST()
    setfpscap(500)
    if game.ReplicatedStorage:FindFirstChild("Assets") then
    game.ReplicatedStorage:FindFirstChild("Assets"):Destroy()
    end
    local decalsyeeted = true
    local g = game
    local w = g.Workspace
    local l = g.Lighting
    local t = w.Terrain
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    l.GlobalShadows = false
    l.FogEnd = 9e9
    l.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for i, v in pairs(g:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then 
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
            v.TextureID = 10385902758728957
        end
    end
    for i, e in pairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
    _G.EnabledFpsBoost = true
end
if not _G.EnabledFpsBoost or _G.EnabledFpsBoost == false then
FPS_BOOST()
end



-- webhook func
function SendWebhook1()
    if SendPlayerDataAsWebhook then

local data = {

   ["content"] = "",
   
   ["avatar_url"] = "https://i.imgur.com/OBqZkBq.png",

   ["embeds"] = {

       {

           ["title"] = 'Player Data Collected! '..tostring(os.date("[%X]")),

           ["description"] = "__Player Info:__".."**\nName:  **"..Name.."\n **Level:  **"..Level.."\n**Bounty: **"..Bounty.."\n**Current Fruit:  **"..DevilFruit.."\n**Race:  **"..Race.."\n**Fragments:  **"..Fragments.."\n**Beli:  **"..Beli.."\n**Valor Level:  **"..Valor,

           ["type"] = "rich",

           ["color"] = tonumber(0x7269da),

           ["thumbnail"] = {
                ["url"] = "https://i.imgur.com/LOkRYqi.png"
           },
           ["fields"] = { -- Make a table
				{ -- now make a new one for each field you wish to add
					["name"] = PlayerCurrentMelee;
					["value"] = "Mastery: "..PlayerCurrentMeleeLevel; -- The text,value or information under the title of the field aka name.
					["inline"] = true; -- means that its either inline with others, from left to right or if it is set to false, from up to down.
				},
				{
					["name"] = PlayerCurrentFruit;
					["value"] = "Mastery: "..PlayerCurrentFruitLevel;
					["inline"] = true;
				},
                {
					["name"] = "";
					["value"] = "";
					["inline"] = true;
				},
                {
					["name"] = PlayerCurrentSword;
					["value"] = "Mastery: "..PlayerCurrentSwordLevel;
					["inline"] = true;
				},
                {
					["name"] = PlayerCurrentGun;
					["value"] = "Mastery: "..PlayerCurrentGunLevel;
					["inline"] = true;
				}
			},

           ["footer"] = {
                ["text"] = "Date: "..tostring(os.date("%d/%m/%Y"))
           },

       }

   }

}

local newdata = game:GetService("HttpService"):JSONEncode(data)
local headers = {

   ["content-type"] = "application/json"

}

request = http_request or request or HttpPost or syn.request

local abcdef = {Url = DiscordWebhookUrl, Body = newdata, Method = "POST", Headers = headers}

request(abcdef)

end
end

function SendWebhook2(msg)
    Content = '';
    Embed = {
        title = msg;
        color = tonumber(0xFF0000);
        description = " ";
    };
    (syn and syn.request or http_request) {
        Url = DiscordWebhookUrl;
        Method = 'POST';
        Headers = {
            ['Content-Type'] = 'application/json';
        };
        Body = game:GetService'HttpService':JSONEncode( { content = Content; embeds = { Embed } } );
    };
    end

function SendDataJson()
    if SendDataAsJson then
        local Name = game.Players.LocalPlayer.Name.."_Data" .. ".json"
        writefile(Name, game:GetService("HttpService"):JSONEncode(PrintTable))

        local fileName = game.Players.LocalPlayer.Name.."_Data" .. ".json" -- Đặt tên tệp JSON của bạn
        local fileData = readfile(fileName) -- Đọc nội dung tệp JSON
        
        -- URL avatar
        local AvatarUrl = "https://i.imgur.com/OBqZkBq.png" -- Thay bằng URL avatar của bạn
        
        -- Tạo nội dung body của yêu cầu với multipart/form-data
        local boundary = "------------------------" .. game:GetService("HttpService"):GenerateGUID(false)
        local body = "--" .. boundary .. "\r\n"
            .. "Content-Disposition: form-data; name=\"file\"; filename=\"" .. fileName .. "\"\r\n"
            .. "Content-Type: application/json\r\n\r\n"
            .. fileData .. "\r\n"
            .. "--" .. boundary .. "\r\n"
            .. "Content-Disposition: form-data; name=\"avatar_url\"\r\n\r\n"
            .. AvatarUrl .. "\r\n"
            .. "--" .. boundary .. "--"
        
        -- Định nghĩa headers
        local headers = {
            ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
            ["Content-Length"] = tostring(#body),
        }
        
        -- Gửi yêu cầu HTTP
        local requestFunction = http_request or request or HttpPost or syn.request
        if requestFunction then
            local response = requestFunction({
                Url = DiscordWebhookUrl, -- Thay trực tiếp URL webhook Discord tại đây
                Method = "POST",
                Headers = headers,
                Body = body,
            })
        
            -- Hiển thị phản hồi để kiểm tra lỗi hoặc thành công
            if response then
                if tonumber(response.StatusCode) < 400 then
                print("Trạng thái: Successfully Excuted")
                game:GetService'StarterGui':SetCore("SendNotification", {
                    Title = "Shin dep trai", -- Notification title
                    Text = "Sent Data Successfully", -- Notification text
                    Icon = "https://i.imgur.com/LOkRYqi.png", -- Notification icon (optional)
                    Duration = 5, -- Duration of the notification (optional, may be overridden if more than 3 notifs appear)
                  })
                else
                print("Trạng thái: Webhook failed")
                end
            else
                print("Không nhận được phản hồi từ máy chủ.")
            end
        else
            print("Không tìm thấy hàm gửi HTTP!")
        end
    end
end


--Run Function
SendWebhook1()

if _G.AutoExecuteData["AutoExecute"] == false then
getAllPlayerData()
pasteDataToSend()
SendDataJson()
print('Sending Data, method: Non AutoExecute')
end
------ Auto Execute 
TimeSaveFileName = game.Players.LocalPlayer.Name.."_ServerTime"..".json"

function readFile()
    local success, result = pcall(function()
        return game:GetService('HttpService'):JSONDecode(readfile(TimeSaveFileName))
    end)
    if success then
        return result
    else return false
    end
end

function GetSavedTime() 
    if readFile() ~= false then
    return game:GetService('HttpService'):JSONDecode(readfile(TimeSaveFileName))
    else
    return false
    end
end

function SaveTime(value)
    writefile(TimeSaveFileName, game:GetService('HttpService'):JSONEncode(value))
end

game:GetService('Players').PlayerRemoving:Connect(function(player)
    if player.Name == game:GetService('Players').LocalPlayer.Name then 
            writefile(TimeSaveFileName, game:GetService('HttpService'):JSONEncode(CountingTime))
        end
end)
CountingTime = 0
ExecutedScriptTime = math.floor(workspace.DistributedGameTime+0.5)


if ExecutedScriptTime + 1.3 >= _G.AutoExecuteData["NotifyTime"] and _G.AutoExecuteData["AutoExecute"] == true then
    print('Sending Data, method: Servertime reached NotifyTime ')
    getAllPlayerData()
    pasteDataToSend()
    SendDataJson()
end

while _G.AutoExecuteData["AutoExecute"] do
    wait(1)
    local getSavedTimeStatus = GetSavedTime()
    local CurrentGameTime = math.floor(workspace.DistributedGameTime+0.5)

    if getSavedTimeStatus == false then

    CountingTime = ( CurrentGameTime ) - ( (_G.AutoExecuteData["NotifyTime"]) * ( CurrentGameTime // (_G.AutoExecuteData["NotifyTime"])  )  )
    print("Current Time1: "..CountingTime.." (".." 0 Saved Time)".." + ".."("..CurrentGameTime.." Server Time)")

    if CountingTime + 1.3 >= _G.AutoExecuteData["NotifyTime"] then
        print('Sending Data, method: no save file')
        getAllPlayerData()
        pasteDataToSend()
        SendDataJson()
    end
    else

    CountingTime = CurrentGameTime - ExecutedScriptTime + getSavedTimeStatus
    print("Current Time2: "..CountingTime.." ("..GetSavedTime().." Saved Time)".." + ".."("..CurrentGameTime.." Server Time)")

    if CountingTime + 1.3 >= _G.AutoExecuteData["NotifyTime"] then
        print('Sending Data, method: saved file')
        getAllPlayerData()
        pasteDataToSend()
        SendDataJson()
        SaveTime(0)
        CountingTime = 0
        ExecutedScriptTime = CurrentGameTime
    end
end
end
