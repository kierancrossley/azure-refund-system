util.AddNetworkString("Refunds.Menu")
util.AddNetworkString("Refunds.Send")

-- API configeration, this cannot be in the shared file 
local apiConfig = {
    ["address"] = "http://azureservers.co/api/webhook/refund.php",
    ["password"] = "" -- removed for public release
}

hook.Add("PlayerSay", "RefundCommand", function(ply, text)
    if string.lower(text) == "!refund" then -- command to open the menu
        if not AzureRefunds.Access[ply:GetUserGroup()] then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"You are not allowed to use this!\")") return end
        net.Start("Refunds.Menu")
        net.Send(ply)
    end
end)

concommand.Add("azure_refund", function(ply, cmd, args) -- console command to open the menu
    if not AzureRefunds.Access[ply:GetUserGroup()] then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"You are not allowed to use this!\")") return end
    net.Start("Refunds.Menu")
    net.Send(ply)
end)

local function findPlayer(sid) -- find player by their SteamID
    for k, v in ipairs(player.GetAll()) do
        if v:SteamID() == sid then
            return v
        end
    end
    return nil
end

local function checkWeapon(classname) -- check weapon exists 
    for k, v in ipairs(weapons.GetList()) do
        if v.ClassName == classname then
            return v
        end
    end
    return nil
end

local function abuseCheck(ply)
    if not IsValid(ply) then return end
    if AzureRefunds.Bypass[ply:GetUserGroup()] then return true end -- are they allowed to bypass this?

    local name = ply:Name()
    local steamID = ply:SteamID()
    local steam64 = ply:SteamID64()

    if ply.AbuseCheck then -- havbe the started the abuse check previously
        ply.AbuseCheck["totalrefunds"] = ply.AbuseCheck["totalrefunds"] + 1
    else
        ply.AbuseCheck = {}
        ply.AbuseCheck["totalrefunds"] = 1
    end

    timer.Stop("Refunds" .. steam64) 
    timer.Create("Refunds" .. steam64, 600, 1, function()
        print("[REFUNDS] " .. name .. " (" .. steamID .. ") finished refund abuse check.")
        if not IsValid(ply) then return end
        ply.AbuseCheck = nil -- reset their total refunds after 10 minutes
    end)

    if ply.AbuseCheck["totalrefunds"] >= 3 then -- if 3 or more refunds in 10 minmutes, remove their rank to prevent abuse
        RunConsoleCommand("ulx", "removeuserid", steamID)
        ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"Your rank has been automatically removed for flagging the refund abuse system!\")")
        
        http.Post(apiConfig["address"], { -- send to Discord channel via API
            password = apiConfig["password"],
            title = "Azure Refunds",
            content = name .. " (" .. steamID .. ") has had their rank removed for flagging the refund abuse system!",
            color = string.format("%.2X%.2X%.2X", 231, 76, 60)
        })

        print("[REFUNDS] " .. name .. " (" .. steamID .. ") failed the refund abuse check!")
        return false
    else
        return true
    end
end

net.Receive("Refunds.Send", function(len, ply)
    if not AzureRefunds.Access[ply:GetUserGroup()] then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"You are not allowed to use this!\")") return end

    local steamID = net.ReadString()
    local recipient = findPlayer(steamID)
    local weapon = checkWeapon(net.ReadString())
    local evidence = net.ReadString()

    if weapon == "" or evidence == "" then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"Please fill in every section!\")") return end -- section left blank
    if recipient == nil then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"That player is not online!\")") return end -- player does not exist
    if weapon == nil then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"That weapon class does not exist!\")") return end -- weapon does not exist
    if AzureRefunds.Blacklist[weapon.ClassName] then ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"That weapon is on the refund blacklist!\")") return end -- weapon on blacklist
    
    local allowed = abuseCheck(ply)
    if not allowed then return end

    recipient:Give(weapon.ClassName) -- give the weapon to the player and then make them select it 
    recipient:SelectWeapon(weapon.ClassName)
    recipient:SendLua("chat.AddText(XeninUI.Theme.Green, \"[NOTIFICATION] \", color_white, \"You have been refunded a " .. weapon.PrintName .. " by " .. ply:Name() .. "!\")")
    ply:SendLua("chat.AddText(XeninUI.Theme.Green, \"[NOTIFICATION] \", color_white, \"You have successfully refunded a " .. weapon.PrintName .. " to " .. recipient:Name() .. "!\")")

    http.Post(apiConfig["address"], { -- send to Discord channel by API
        password = apiConfig["password"],
        title = "Azure Refunds",
        content = ply:Name() .. " (" .. ply:SteamID() .. ") has issued a refund! \n\n **Recipient:** " .. recipient:Name() .. " (" .. steamID .. ")\n **Weapon:** " .. weapon.PrintName .. "\n **Evidence:** " .. evidence,
        color = string.format("%.2X%.2X%.2X", 230, 153, 58)
    })
end)