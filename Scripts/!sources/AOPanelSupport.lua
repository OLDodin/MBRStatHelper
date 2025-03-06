local IsAOPanelEnabled = true

function onAOPanelStart( params )
	if IsAOPanelEnabled then
	
		local SetVal = { val = userMods.ToWString( "MBR" ) }
		local params = { header = SetVal, ptype = "button", size = 54 }
		userMods.SendEvent( "AOPANEL_SEND_ADDON",
			{ name = common.GetAddonName(), sysName = common.GetAddonName(), param = params } )

		DnD.HideWdg(getChild(mainForm, "AORBMButton"))
	end
end

function onAOPanelLeftClick( params )
	if params.sender == common.GetAddonName() then
		ChangeMainWndVisible()
	end
end

function onAOPanelRightClick( params )
end

function onAOPanelChange( params )
	if params.unloading and string.find(params.name, "AOPanel") then
		DnD.ShowWdg(getChild(mainForm, "AORBMButton"))
	end
end
