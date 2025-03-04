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

DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1330919833021448295/Ggnx_R8eLKAVgbawIk3rFbxJIUix2KSOBU-KlBGaJvyUIdDP7qgHF__YlQduNx_d3BWW"
AUTO_EXECUTE_CONFIG = {
    Enabled = true,
    Interval = 3600,
    NotifyThreshold = 1.3
}

-- Định dạng luồng dữ liệu
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer



--------------------------------------------
--- [ = = = = = = = \ MAIN / = = = = = = = ]
--------------------------------------------

-- Lấy combo
function getTool(path)
    local toolTypes = {
        ["Melee"] = "PlayerCurrentMelee",
        ["Blox Fruit"] = "PlayerCurrentFruit",
        ["Sword"] = "PlayerCurrentSword",
        ["Gun"] = "PlayerCurrentGun"
    }
    
    for _, tool in pairs(path:GetChildren()) do
        if tool:IsA("Tool") and toolTypes[tool.ToolTip] then
            _G[toolTypes[tool.ToolTip]] = tool.Name
            _G[toolTypes[tool.ToolTip] .. "Level"] = tool.Level.Value
        end
    end
end

-- Lấy dữ liệu người dùng
function getPlayerData()
    Name       = LocalPlayer.Name
    Level      = LocalPlayer.Data.Level.Value
    Bounty     = LocalPlayer.leaderstats["Bounty/Honor"].Value
    DevilFruit = LocalPlayer.Data.DevilFruit.Value
    Race       = LocalPlayer.Data.Race.Value
    Fragments  = LocalPlayer.Data.Fragments.Value
    Beli       = LocalPlayer.Data.Beli.Value
    Valor      = LocalPlayer.Data.Valor.Value
    FruitCap   = LocalPlayer.Data.FruitCap.Value

    PlayerCurrentMelee, PlayerCurrentMeleeLevel = "", ""
    PlayerCurrentSword, PlayerCurrentSwordLevel = "", ""
    PlayerCurrentFruit, PlayerCurrentFruitLevel = "", ""
    PlayerCurrentGun  , PlayerCurrentGunLevel   = "", ""


    -- Lấy trái ác quỷ và kho đồ (BloxFruit)
    ReplicatedStorage.Remotes.SubclassNetwork.GetPlayerData:InvokeServer()
    ReplicatedStorage.Remotes.GetFruitData:InvokeServer()
    local Fruit = ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits", false)
    local Inventory = ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")

    -- Lấy kho đồ và nhân vật (Roblox)
    local backpack = LocalPlayer.Backpack
    local character = LocalPlayer.Character
    
    -- Lấy dữ liệu từ tộc
    raceData = {
        ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Check"),
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1"),
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist")
    }

    -- Kiểm tộc (race)
    RaceAwakenValue = 1 -- v1 (mặc định)
    if raceData[1] == 4 then
        RaceAwakenValue = 4 -- v4
    elseif raceData[2] == -2 then
        RaceAwakenValue = 3 -- v3
    elseif raceData[3] == -2 then
        RaceAwakenValue = 2 -- v2
    end

    -- Lấy EliteHunter và SpyStatus
    EliteHunterProcess = ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
    SpyStatus = ReplicatedStorage.Remotes.CommF_:InvokeServer("InfoLeviathan", 1)

    if Sea[game.PlaceId] ~= 3 then
        EliteHunterProcess = "Không tìm thấy"
        SpyText = "Không tìm thấy"
    else
        EliteHunterProcess = "Total Killed Elite Hunter: " .. EliteHunterProcess
        if SpyStatus == -1 then
            SpyText = "Spy: Still in Cooldown"
        else
            SpyText = "Spy: Found Leviathan"
        end
    end

    -- Lấy combo
    pcall(function() getTool(backpack) end)
    pcall(function() getTool(character) end)
end

-------------
--Paste Player Data
function pasteDataToSend()
    pcall(function()
        FruitTable2 = {}
        PlayerFruitTable2 = {}
        TestTable2 = {}
        PlayerFruitData = {}

        ---Get Player Melee
        PrintMelee = ""
        NameMelee = {"BlackLeg","Electro","FishmanKarate","DragonClaw","Superhuman","DeathStep","SharkmanKarate","ElectricClaw","DragonTalon","Godhuman","SanguineArt"}
        for i,v in pairs(NameMelee) do
            if v == "DragonClaw" then  
                local a = ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward","DragonClaw","1") 
                if a == 1 or a == 2 then
                    PrintMelee = PrintMelee..v..", "
                end
            else
                local a = ReplicatedStorage.Remotes.CommF_:InvokeServer("Buy"..v,true)
            if a == 1 or a == 2 then
           PrintMelee = PrintMelee..v..", "
        end
        end
    end

        function splitCamelCase(str)
            return str:gsub("([a-z])([A-Z])", "%1 %2") -- Thêm khoảng trắng giữa chữ hoa và chữ thường
        end
        -- Tách các từ trong chuỗi và xử lý chúng
        local result = {}
        for word in PrintMelee:gmatch("%S+") do
            table.insert(result, tostring(splitCamelCase(word)))
        end
        
        -- Kết hợp các từ đã tách lại thành một chuỗi, cách nhau bởi dấu phẩy
        finalResult = table.concat(result, " ")
    --
            -- ListFruit from FruitStock:
            for i,v in pairs(Fruit) do
                for a,b in pairs(v) do
                       if a == "Name" or a == "Rarity" then
                        if b ~= "Dragon-Dragon" then
                    table.insert(FruitTable2,b)
                        else
                            ---Insert Dragon
                            table.insert(FruitTable2,"Dragon (West)-Dragon (West)")
                            table.insert(FruitTable2,4)
                            table.insert(FruitTable2,"Dragon (East)-Dragon (East)")
                            table.insert(FruitTable2,4)
                        end
                    end
                end
            end
             
             
            ---
            for i,v in pairs(Inventory) do
                if table.find(FruitTable2,v.Name) then               
                    table.insert(TestTable2,v.Name)
                end
            end
            ---
            for i,v in pairs(Inventory) do
                if table.find(FruitTable2,v.Name) then               
                            table.insert(PlayerFruitData,v)
                end
           end
          
            ---
    PrintTable = "Player Name: "..Name..", ".."Level: "..Level..", ".."Bounty: "..Bounty..", ".."Race: "..Race.." [V"..tostring(RaceAwakenValue).."]"..", ".."Fragments: "..Fragments..", ".."Beli: "..Beli..", ".."Valor Level: "..Valor..", ".."Fruit Capacity: "..FruitCap..EliteHunterProcess..SpyText.." | ".."CurrentMelee: "..PlayerCurrentMelee..", ".."Mastery: "..PlayerCurrentMeleeLevel.." | ".."CurrentBloxFruit: "..PlayerCurrentFruit..", ".."Mastery: "..PlayerCurrentFruitLevel.." | ".."CurrentSword: "..PlayerCurrentSword..", ".."Mastery: "..PlayerCurrentSwordLevel.." | ".."CurrentGun: "..PlayerCurrentGun..", ".."Mastery: "..PlayerCurrentGunLevel.." | ".."Melee: "..finalResult:sub(1,-2).." | "
           for i,v in ipairs(FruitTable2) do
            if type(v) == "string" then
            NameFruit = v
            if table.find(TestTable2,v) then
                PrintTable = PrintTable.."Fruit Name: "..NameFruit..", "
                for l,k in pairs(PlayerFruitData) do
                    if k.Name == NameFruit then
                        for a,b in pairs(k) do
                            if a ~= "AwakeningData" and a ~= "Equipped" and a~= "MasteryRequirements" and a ~= "Type" and a~= "Name" and a ~= "Value" then
                                if a~= "Mastery" then
                                PrintTable = PrintTable..a..": "..b..", "
                                else
                                    PrintTable = PrintTable..a..": "..b.." | "
                                end
                            end
                        end
                    end
                end
            else
               PrintTable = PrintTable.."Fruit Name: "..v..", ".."Rarity: "..FruitTable2[i+1]..", ".."Count: 0"..", ".."Mastery: - | "
           end

        end
    end
    
               for i,v in pairs(Inventory) do
                        for i1,v1 in pairs(v) do
                            if v.Type == "Sword"  then
                                if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" then
                                    if i1 == "Name" then
                                        PrintTable = PrintTable.."Sword "..i1..": "..v1..", "
                                        else
                                            if i1 == "Mastery" then
                                                PrintTable = PrintTable..i1..": "..v1.." | "
                                                else
                                                PrintTable = PrintTable..i1..": "..v1..", "
                                            end
                                    end
                            end
                        end
                    end
               end
               for i,v in pairs(Inventory) do
                for i1,v1 in pairs(v) do
                    if v.Type == "Gun"  then
                        if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" then
                            if i1 == "Name" then
                                PrintTable = PrintTable.."Gun "..i1..": "..v1..", "
                                else
                                    if i1 == "Mastery" then
                                        PrintTable = PrintTable..i1..": "..v1.." | "
                                        else
                                        PrintTable = PrintTable..i1..": "..v1..", "
                                    end
                            end
                    end
                end
            end
       end
                for i,v in pairs(Inventory) do
                    for i1,v1 in pairs(v) do
                        if v.Type == "Wear"  then
                            if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" then
                                if i1 == "Name" then
                                    PrintTable = PrintTable.."Accessory "..i1..": "..v1..", "
                                    else
                                        if i1 == "Mastery" then
                                            PrintTable = PrintTable..i1..": "..v1.." | "
                                            else
                                            PrintTable = PrintTable..i1..": "..v1..", "
                                        end
                                end
                        end
                    end
                end
                end
                for i,v in pairs(Inventory) do
                    for i1,v1 in pairs(v) do
                        if v.Type == "Material"  then
                            if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" then
                                if i1 == "Name" then
                                    PrintTable = PrintTable.."Material "..i1..": "..v1..", "
                                    else
                                        if i1 == "MaxCount" then
                                            PrintTable = PrintTable..i1..": "..v1.." | "
                                            else
                                            PrintTable = PrintTable..i1..": "..v1..", "
                                        end
                                end
                        end
                    end
                end
                end
               
                for i,v in pairs(Inventory) do
                    for i1,v1 in pairs(v) do
                        if v.Type == "Premium"  then
                            if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" and i1 ~= "Value" and i1 ~= "Texture" then
                                if i1 == "Name" then
                                    PrintTable = PrintTable.."Premium "..i1..": "..v1..", "
                                    else
                                        if i1 == "SubType" then
                                            PrintTable = PrintTable..i1..": "..v1.." | "
                                            else
                                            PrintTable = PrintTable..i1..": "..v1..", "
                                        end
                                end
                        end
                    end
                end
                end

                for i,v in pairs(Inventory) do
                    for i1,v1 in pairs(v) do
                        if v.Type == "Scroll"  then
                            if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" and i1 ~= "Value" and i1 ~= "Texture" then
                                if i1 == "Name" then
                                    PrintTable = PrintTable.."Scroll "..i1..": "..v1..", "
                                    else
                                        if i1 == "MaxCount" then
                                            PrintTable = PrintTable..i1..": "..v1.." | "
                                            else
                                            PrintTable = PrintTable..i1..": "..v1..", "
                                        end
                                end
                        end
                    end
                end
                end

                for i,v in pairs(Inventory) do
                    for i1,v1 in pairs(v) do
                        if v.Type == "Usable"  then
                            if i1 ~= "Rarity" and i1 ~= "MasteryRequirements" and i1 ~= "Scrolls" and i1 ~= "Equipped" and i1 ~= "Type" and i1 ~= "Value" and i1 ~= "Texture" then
                                if i1 == "Name" then
                                    PrintTable = PrintTable.."Useable "..i1..": "..v1..", "
                                    else
                                        if i1 == "MaxCount" then
                                            PrintTable = PrintTable..i1..": "..v1.." | "
                                            else
                                            PrintTable = PrintTable..i1..": "..v1..", "
                                        end
                                end
                        end
                    end
                end
                end
                        
    end)
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
