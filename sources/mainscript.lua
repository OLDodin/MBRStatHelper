local m_typesArr = {}
local m_reactions={}
local m_configForm = nil
local m_template = nil
local m_mWdg = nil
local m_rWdg = nil
local m_bWdg = nil
local m_amuletInfo = nil
local m_shopCheckBox = nil
local m_alhimCheckBox = nil
local m_ordenCheckBox = nil
local m_rEditLine = nil
local m_eatRCheckBox = nil

function AddReaction(name, func)
	if not m_reactions then m_reactions={} end
	m_reactions[name]=func
end

function RunReaction(widget)
	local name=getName(widget)
	if not name or not m_reactions or not m_reactions[name] then return end
	m_reactions[name]()
end

function ButtonPressed(params)
	RunReaction(params.widget)
	changeCheckBox(params.widget)
end

function ChangeMainWndVisible()
	if isVisible(m_configForm) then
		hide(m_configForm)
	else
		show(m_configForm)
	end
	setLocaleText(m_mWdg)
	setLocaleText(m_rWdg)
	setLocaleText(m_bWdg)
end

local function GetTimestamp()
	return common.GetMsFromDateTime( common.GetLocalDateTime() )
end


local function CalcDD(aM, aR, aB, aRLvl)
	return (1+0.001*aM)*(1+0.001*aB)*(1+0.0015*aRLvl*aR)
end

local function CalcDDExt(aM, aR, aB, aRLvl, aPhis, aStih, aBozh, aPrirod, aDmgTypesKoef)
	return (1+0.001*aM)*(1+0.001*aB)*(1+0.0015*aRLvl*aR)*(1+0.001296*aPhis*aDmgTypesKoef[0])*(1+0.001296*aStih*aDmgTypesKoef[1])*(1+0.001296*aBozh*aDmgTypesKoef[2])*(1+0.001296*aPrirod*aDmgTypesKoef[3])
end

local function CheckPercentVal(aVal, aDefaultVal, aWdg)
	if not aVal or aVal < 0 or aVal > 100 then
		aVal = aDefaultVal
		setText(aWdg, tostring(aVal))
	end
	return aVal
end

function CalcPressed()
	local currMaster = 0
	local currResh = 0
	local currBesp = 0
	local currPhis = 0
	local currStih = 0
	local currBozh = 0
	local currPrirod = 0
	local useTypes = false
	local dmgTypesKoef = {}
	for i = 0, 3 do
		local typeProcent = CheckPercentVal(tonumber(getText(m_typesArr[i].editWdg)), 0, m_typesArr[i].editWdg)
		if typeProcent ~= 0 then
			useTypes = true
		end
		dmgTypesKoef[i] = typeProcent / 100
	end

	local stats = avatar.GetInnateStats()
	for i = 0, GetTableSize( stats ) - 1 do
		local stat = stats[i]
		if stat.sysName == "ENUM_InnateStats_Plain" then
			currMaster = stat.effective-stat.buffs
		end
		if stat.sysName == "ENUM_InnateStats_Rage" then
			currResh = stat.effective-stat.buffs
		end
		if stat.sysName == "ENUM_InnateStats_Finisher" then
			currBesp = stat.effective-stat.buffs
		end
	end
	if useTypes then
		local specStats = avatar.GetSpecialStats()
		for i = 1, GetTableSize( specStats ) do
			if toString(specStats[i].name) == "Физический урон" then 
				currPhis = specStats[i].effective-specStats[i].buffs
			end
			if toString(specStats[i].name) == "Стихийный урон" then 
				currStih = specStats[i].effective-specStats[i].buffs
			end
			if toString(specStats[i].name) == "Божественный урон" then 
				currBozh = specStats[i].effective-specStats[i].buffs
			end
			if toString(specStats[i].name) == "Природный урон" then 
				currPrirod = specStats[i].effective-specStats[i].buffs
			end		
		end
	end
	
	local amuletBonus = 0
	local myDressedSlots = unit.GetEquipmentItemIds(avatar.GetId(), ITEM_CONT_EQUIPMENT) 
	local amulet = myDressedSlots[DRESS_SLOT_TRINKET]
	if amulet then
		local itemQuality = itemLib.GetQuality( amulet )
		local quality = itemQuality and itemQuality.quality
		--150 200 230 250 к мастерству раз в 60с на 15с + некоторое время на срабатывание 10-25%
		if quality == ITEM_QUALITY_UNCOMMON then
			amuletBonus = 30
		elseif quality == ITEM_QUALITY_RARE then
			amuletBonus = 45
		elseif quality == ITEM_QUALITY_EPIC then
			amuletBonus = 51
		elseif quality == ITEM_QUALITY_LEGENDARY then
			amuletBonus = 60
		end
	end
	
	local rLevelTxt = getText(m_rEditLine)
	local rLevelVal = tonumber(rLevelTxt)
	rLevelVal = CheckPercentVal(rLevelVal, 95, m_rEditLine)
	
	rLevelVal = rLevelVal / 100
	
	local useShop = getCheckBoxState(m_shopCheckBox)
	local useOrden = getCheckBoxState(m_ordenCheckBox)
	local useAlhim = getCheckBoxState(m_alhimCheckBox)
	local useEatR = getCheckBoxState(m_eatRCheckBox)
	local summaStat = currMaster+currResh+currBesp+amuletBonus
	if useShop then 
		summaStat = summaStat + 100
	end	
	if useAlhim then
		summaStat = summaStat + 50
	end
	
	local maxRes = {}
	maxRes.value = 0
	maxRes.m = 0
	maxRes.r = 0
	maxRes.b = 0
	maxRes.phis = 0
	maxRes.stih = 0
	maxRes.bozh = 0
	maxRes.prirod = 0
	if useTypes then
		summaStat = summaStat + currPhis + currStih + currBozh + currPrirod
		local typesLimit = 250
		local step = 10
		local elapsedStat = summaStat
		if dmgTypesKoef[0]>0 and dmgTypesKoef[1]>0 and dmgTypesKoef[2]>0 and dmgTypesKoef[3]>0 then
			step = 15
		end
		for phis=0, dmgTypesKoef[0]>0 and typesLimit or 1, step do
			for stih=0, dmgTypesKoef[1]>0 and typesLimit or 1, step do
				for bozh=0, dmgTypesKoef[2]>0 and typesLimit or 1, step do
					for prirod=0, dmgTypesKoef[3]>0 and typesLimit or 1, step do
						elapsedStat = summaStat-phis-bozh-stih-prirod
						for m=amuletBonus, elapsedStat, step do
							for b=0, elapsedStat-m, step do
								local r = elapsedStat-b-m
								if useOrden then
									r = r + 100
								end
								if useEatR then
									r = r + 25
								end
								local res = CalcDDExt(m, r, b, rLevelVal, phis, stih, bozh, prirod, dmgTypesKoef)
								if res > maxRes.value then
									maxRes.value = res
									maxRes.m = m
									maxRes.r = r
									maxRes.b = b
									maxRes.phis = phis
									maxRes.stih = stih
									maxRes.bozh = bozh
									maxRes.prirod = prirod
								end
							end
						end
					end
				end
			end
		end	
		setText(m_typesArr[0].resultTxtWdg, tostring(math.floor(maxRes.phis)))
		setText(m_typesArr[1].resultTxtWdg, tostring(math.floor(maxRes.stih)))
		setText(m_typesArr[2].resultTxtWdg, tostring(math.floor(maxRes.bozh)))
		setText(m_typesArr[3].resultTxtWdg, tostring(math.floor(maxRes.prirod)))
	else
		for m=amuletBonus, summaStat do
			for b=0, summaStat-m do
				local r = summaStat-b-m
				if useOrden then
					r = r + 100
				end
				if useEatR then
					r = r + 25
				end
				local res = CalcDD(m, r, b, rLevelVal)
				if res > maxRes.value then
					maxRes.value = res
					maxRes.m = m
					maxRes.r = r
					maxRes.b = b
				end
			end
		end
		for i = 0, 3 do
			setLocaleText(m_typesArr[i].resultTxtWdg)
		end	
	end
	--[[if useOrden then
		maxRes.r = maxRes.r - 100
	end]]--
	--LogInfo("find res = ", maxRes.value, " myCurrRes = ", myCurrRes, " m= ", maxRes.m, " r= ", maxRes.r, " b= ", maxRes.b)
	
	setText(m_mWdg, tostring(math.floor(maxRes.m-amuletBonus)))
	setText(m_rWdg, tostring(math.floor(maxRes.r)))
	setText(m_bWdg, tostring(math.floor(maxRes.b)))
	
	
	
	if amuletBonus > 0 then
		setText(m_amuletInfo, getLocale()["amuletInfo"]..tostring(amuletBonus))
	else
		setText(m_amuletInfo, "")
	end
end


function InitConfigForm()
	setTemplateWidget(m_template)
	local formWidth = 500
	local form=createWidget(mainForm, "ConfigForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, formWidth, 600, 100, 120)
	priority(form, 5500)
	hide(form)
	local grShiftX = 25
	local grShiftY = 140

	local btnWidth = 220
	
	setLocaleText(createWidget(form, "calcButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, btnWidth, 25, formWidth/2-btnWidth/2, 570))

	local descWdg = createWidget(form, "desc", "TextView", nil, nil, formWidth-25*2, 200, 25, 30)
	setLocaleText(descWdg)
	descWdg:SetMultiline(true)
	
	setLocaleText(createWidget(form, "lineM", "TextView", nil, nil, 600, 25, grShiftX, grShiftY))
	setLocaleText(createWidget(form, "lineR", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30))
	setLocaleText(createWidget(form, "lineB", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*2))

	m_mWdg = createWidget(form, "resM", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY)
	m_rWdg = createWidget(form, "resR", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30)
	m_bWdg = createWidget(form, "resB", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*2)
	
	m_amuletInfo = createWidget(form, "amuletInfo", "TextView", nil, nil, formWidth-grShiftX*2, 60, grShiftX, grShiftY+30*2+15)
	m_amuletInfo:SetMultiline(true)
	
	m_eatRCheckBox = createWidget(form, "useEatR", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 460)
	m_alhimCheckBox = createWidget(form, "useAlhim", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 485)
	m_shopCheckBox = createWidget(form, "useShop", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 510)
	m_ordenCheckBox = createWidget(form, "useOrden", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 535)
	setCheckBox(m_eatRCheckBox, false)
	setCheckBox(m_shopCheckBox, false)
	setCheckBox(m_ordenCheckBox, false)
	setCheckBox(m_alhimCheckBox, false)
	
	local wdg = createWidget(form, "amountOfR", "TextView", nil, nil, 160, 60, grShiftX, 510)
	wdg:SetMultiline(true)
	setLocaleText(wdg)
	m_rEditLine = createWidget(form, "EditLine1", "EditLine", nil, nil, 40, 25, 90, 524, nil, nil)
	setText(m_rEditLine, "95")
	
	setLocaleText(m_eatRCheckBox)
	setLocaleText(m_shopCheckBox)
	setLocaleText(m_ordenCheckBox)
	setLocaleText(m_alhimCheckBox)
	setLocaleText(m_mWdg)
	setLocaleText(m_rWdg)
	setLocaleText(m_bWdg)
	
	
	local specDescWdg = createWidget(form, "specialDesc", "TextView", nil, nil, formWidth-25*2, 100, grShiftX, grShiftY+30*4)
	setLocaleText(specDescWdg)
	specDescWdg:SetMultiline(true)
	
	
	for i = 0, 3 do
		m_typesArr[i] = {}
		local posY = grShiftY+30*6 + i*30 + 20
		setLocaleText(createWidget(form, "type"..(i+1), "TextView", nil, nil, 300, 30, grShiftX, posY))
		m_typesArr[i].editWdg = createWidget(form, "typeVal"..(i+1), "EditLine", nil, nil, 40, 25, 270, posY-2, nil, nil)
		m_typesArr[i].resultTxtWdg = createWidget(form, "resType"..(i+1), "TextView", nil, nil, 150, 30, formWidth/2+100, posY)
		setText(m_typesArr[i].editWdg, "0")
		setLocaleText(m_typesArr[i].resultTxtWdg)
	end	

	setText(createWidget(form, "closeBarsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 14), "x")
	DnD:Init(form, form, true)
	AddReaction("closeBarsButton", function () ChangeMainWndVisible() end)
	
	AddReaction("calcButton", CalcPressed)
	
	return form
end


function Init()
	m_template = createWidget(nil, "Template", "Template")
	setTemplateWidget(m_template)
		
	local button=createWidget(mainForm, "AORBMButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 50, 25, 300, 120)
	setText(button, "MBR")
	DnD:Init(button, button, true)
	
	common.RegisterReactionHandler(ButtonPressed, "execute")

	m_configForm = InitConfigForm()
	
	AddReaction("AORBMButton", function () ChangeMainWndVisible() end)
	common.RegisterEventHandler( onAOPanelStart, "AOPANEL_START" )
	common.RegisterEventHandler( onAOPanelLeftClick, "AOPANEL_BUTTON_LEFT_CLICK" )
	common.RegisterEventHandler( onAOPanelRightClick, "AOPANEL_BUTTON_RIGHT_CLICK" )
	common.RegisterEventHandler( onAOPanelChange, "EVENT_ADDON_LOAD_STATE_CHANGED" )
end

if (avatar.IsExist()) then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end