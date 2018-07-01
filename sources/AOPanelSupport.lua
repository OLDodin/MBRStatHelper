local IsAOPanelEnabled = GetConfig( "EnableAOPanel" ) or GetConfig( "EnableAOPanel" ) == nil

function onAOPanelStart( params )
	if IsAOPanelEnabled then
	
		local SetVal = { val = userMods.ToWString( "MBR" ) }
		local params = { header = SetVal, ptype = "button", size = 54 }
		userMods.SendEvent( "AOPANEL_SEND_ADDON",
			{ name = common.GetAddonName(), sysName = common.GetAddonName(), param = params } )

		hide(getChild(mainForm, "AORBMButton"))
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
	if params.unloading and params.name == "UserAddon/AOPanelMod" then
		show(getChild(mainForm, "AORBMButton"))
	end
end

function enableAOPanelIntegration( enable )
	IsAOPanelEnabled = enable
	SetConfig( "EnableAOPanel", enable )

	if enable then
		onAOPanelStart()
	else
		show(getChild(mainForm, "AORBMButton"))
	end
end
