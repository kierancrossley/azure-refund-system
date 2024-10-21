XeninUI:CreateFont("refundSmall", 15)
XeninUI:CreateFont("refundLarge", 21)

net.Receive("Refunds.Menu", function()
    local frameW, frameH = ScrW()/4, ScrH()/3.5 -- scale to screensize
    local opening = true

    local frame = vgui.Create("XeninUI.Frame") -- main frame 
    frame:SetSize(0, 0)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Refund Menu")
    frame:SizeTo(frameW, frameH, 1.8, 0, 0.1, function()
        opening = false
    end)
    frame.Think = function(pnl)
        if (opening) then
            pnl:Center()
        end
    end

    local panel = vgui.Create("DPanel", frame) -- background panel
    panel:Dock(FILL)
    panel:DockMargin(12, 12, 12, 12)
    panel:SetTall(frameH-24)
    panel.Paint = function(pnl, w, h)
      draw.RoundedBox(5, 0, 0, w, h, XeninUI.Theme.Navbar)
    end

    local selected = panel:Add("DButton") -- player selector
    selected:Dock(TOP)
    selected:DockMargin(0, 0, 0, 12)
    selected:SetTall(frameH*0.25)
    selected:SetText("")
    selected.Text = "Unselected Player"
    selected.Sid64 = ""
    selected.Sid = "Click to select!"
    selected.Usergroup = ""
    selected.Background = XeninUI.Theme.Primary
    selected.TextColor = Color(222, 222, 222)
    selected.Paint = function(pnl, w, h)
        XeninUI:DrawRoundedBoxEx(5, 0, 0, w, h, pnl.Background, true, true, false, false)

        XeninUI:DrawShadowText(pnl.Text, "XeninUI.DropdownPopup", h + 6, h / 2 + 1, pnl.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
        XeninUI:DrawShadowText(pnl.Sid, "XeninUI.DropdownPopup.Small", h + 6, h / 2 + 1, ColorAlpha(pnl.TextColor, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)
    end
    selected.OnCursorEntered = function(pnl)
        pnl:LerpColor("Background", Color(55, 55, 55))
        pnl:LerpColor("TextColor", color_white)
    end
    selected.OnCursorExited = function(pnl)
        pnl:LerpColor("Background", XeninUI.Theme.Primary)
        pnl:LerpColor("TextColor", Color(222, 222, 222))
    end

    local avatar = selected:Add("XeninUI.Avatar")
    avatar:SetVertices(30)
    avatar:SetPlayer(BOT, 64)
    selected.PerformLayout = function(pnl, w, h)
        avatar:SetPos(18, 12)
        avatar:SetSize(h - 24, h - 24)
    end
    selected.DoClick = function(pnl)
        local choose = panel:Add("XeninUI.PlayerDropdown")
        choose:SetParentPanel(selected)
        choose:SetData(player.GetAll())
        choose:SetDrawOnTop(true)
        choose:MakePopup()
        local x, y = selected:LocalToScreen()
        choose:SetPos(x, y)
        choose.OnSelected = function(pnl, sid64)
            if not sid64 then return end
            local ply = player.GetBySteamID64(sid64)
            
            selected.Text = ply:Name()
            selected.Sid = ply:SteamID()
            avatar:SetPlayer(ply, 64)
        end
    end

    local elementH = ((panel:GetTall()-selected:GetTall())-6)/3-24

    local weapon = panel:Add("XeninUI.TextEntry") -- weapon input
    weapon:SetLabel("Weapon: ", LEFT)
    weapon:Dock(TOP)
    weapon:DockMargin(12, 0, 12, 6)
    weapon:SetSize(frameW-24, elementH)
    weapon:SetBackgroundColor(XeninUI.Theme.Background)
    weapon:SetFont("refundSmall")
    weapon.textentry.OnValueChange = function(pnl, text)
        frame:Remove()
    end

    local evidence = panel:Add("XeninUI.TextEntry") -- evidence input
    evidence:SetLabel("Evidence: ", LEFT)
    evidence:Dock(TOP)
    evidence:DockMargin(12, 0, 12, 6)
    evidence:SetTall(elementH)
    evidence:SetBackgroundColor(XeninUI.Theme.Background)
    evidence:SetFont("refundSmall")

    local refund = panel:Add("XeninUI.ButtonV2") -- submit refund button
    refund:SetText("Send Refund")
    refund:SetFont("refundLarge")
    refund:Dock(TOP)
    refund:DockMargin(12, 0, 12, 0)
    refund:SetTall(elementH)
    refund:SetRoundness(5)
    refund:SetSolidColor(XeninUI.Theme.Green)
    refund.DoClick = function()
        net.Start("Refunds.Send")
            net.WriteString(selected.Sid)
            net.WriteString(weapon:GetText())
            net.WriteString(evidence:GetText())
        net.SendToServer()
    end
end)