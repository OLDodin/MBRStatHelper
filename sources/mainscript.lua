local m_reactions={}
local m_configForm = nil
local m_template = nil
local m_mWdg = nil
local m_rWdg = nil
local m_bWdg = nil
local m_critWdg = nil
local m_amuletInfo = nil
local m_shopCheckBox = nil
local m_alhimCheckBox = nil
local m_doblestCheckBox = nil
local m_ornamentCheckBox = nil
local m_ordenCheckBox = nil
local m_rEditLine = nil
local m_artEditLine = nil
local m_eatRCheckBox = nil
local m_guildCritCheckBox = nil
local m_diffWdg = nil

local KILL_TIME = 1
local DD_KOEF = 2
local MAX_HP = 1000

local DOBLEST_M = 1
local DOBLEST_R = 2
local DOBLEST_B = 3

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
		DnD.HideWdg(m_configForm)
	else
		DnD.ShowWdg(m_configForm)
	end
	setLocaleText(m_mWdg)
	setLocaleText(m_rWdg)
	setLocaleText(m_bWdg)
	setLocaleText(m_critWdg)
	setLocaleText(m_diffWdg)
end

function GetArtBonus(anArtLevel)
	if anArtLevel == 0 then
		return 1
	end
	local startBonus = 1.025
	if anArtLevel <= 5 then
		return 1.025 + 0.0125*(anArtLevel-1)
	else
		return 1.075 + 0.002777*(anArtLevel-1)
	end
end

local function GetTimestamp()
	return common.GetMsFromDateTime( common.GetLocalDateTime() )
end

local function FloorToStep(aNum, aStep)
   return math.floor(aNum/aStep+0.5)*aStep
end

local function GetCritPart(aCrit)
	if aCrit <= 750 then
		return 1+0.0004*aCrit
	else
		return 1+(0.0004-0.0000001906*(aCrit-750))*aCrit
	end
end

local function CalcDD(aM, aR, aB, aCrit, aRLvl)
	return (1+0.0005*aM)*(1+0.0005*aB)*(1+0.00075*aRLvl*aR)*GetCritPart(aCrit)
end


local function CalcKillTime(aM, aR, aB, aCrit, aRLvl, aFullHP)
	local currHP = aFullHP
	local killTime = 0
	local constPart1 = (1+0.0005*aM)*(1+0.00075*aRLvl*aR)*GetCritPart(aCrit)
	local constPart2 = (0.001 + 0.00000012852*aB)*aB
	while currHP > 0 do
		currHP = currHP - constPart1*(1 + constPart2*(1-currHP/aFullHP))
		killTime = killTime + 1
	end
	
	return killTime
end

local function CalcResult(aM, aR, aB, aCrit, aRLvl, aType, aFullHP)
	if aType == DD_KOEF then
		return CalcDD(aM, aR, aB, aCrit, aRLvl)
	elseif aType == KILL_TIME then
		return CalcKillTime(aM, aR, aB, aCrit, aRLvl, aFullHP)
	end
end

local function CheckPercentVal(aVal, aDefaultVal, aMinVal, aMaxVal, aWdg)
	if not aVal or aVal < aMinVal or aVal > aMaxVal then
		aVal = aDefaultVal
		setText(aWdg, tostring(aVal))
	end
	return aVal
end

local function IsBetterResult(anOldResult, aNewResult, aType)
	if anOldResult == 0 then
		return true
	end
	if aType == DD_KOEF then
		return aNewResult > anOldResult
	elseif aType == KILL_TIME then
		return aNewResult < anOldResult
	end
end

function CalcPressed1()
	CalcPressed(DD_KOEF)
end

function CalcPressed2()
	CalcPressed(KILL_TIME)
end

function CalcPressed(aType)
	local realMaster = 0
	local realResh = 0
	local realBesp = 0
	local realCrit = 0

	local currMaster = 0
	local currResh = 0
	local currBesp = 0
	local currCrit = 0
	
	local stats = avatar.GetInnateStats()
	for i = 0, GetTableSize( stats ) - 1 do
		local stat = stats[i]
		if stat.sysName == "ENUM_InnateStats_Plain" then
			currMaster = stat.effective-stat.buffs
			realMaster = stat.effective
		end
		if stat.sysName == "ENUM_InnateStats_Rage" then
			currResh = stat.effective-stat.buffs
			realResh = stat.effective
		end
		if stat.sysName == "ENUM_InnateStats_Finisher" then
			currBesp = stat.effective-stat.buffs
			realBesp = stat.effective
		end
	end

	local specStats = avatar.GetSpecialStats()
	for i = 1, GetTableSize( specStats ) do
		if toString(specStats[i].name) == "Удача" then 
			currCrit = specStats[i].effective-specStats[i].buffs
			realCrit = specStats[i].effective
			break
		end
	end

	
	local amuletBonus = 0
	local myDressedSlots = unit.GetEquipmentItemIds(avatar.GetId(), ITEM_CONT_EQUIPMENT) 
	local amulet = myDressedSlots[DRESS_SLOT_TRINKET]
	if amulet then
		local itemQuality = itemLib.GetQuality( amulet )
		local quality = itemQuality and itemQuality.quality
		--150 200 230 250 270 к мастерству раз в 60с на 15с + некоторое время на срабатывание 10-25%
		if quality == ITEM_QUALITY_UNCOMMON then
			amuletBonus = 30
		elseif quality == ITEM_QUALITY_RARE then
			amuletBonus = 45
		elseif quality == ITEM_QUALITY_EPIC then
			amuletBonus = 51
		elseif quality == ITEM_QUALITY_LEGENDARY then
			amuletBonus = 60
		elseif quality == ITEM_QUALITY_RELIC then
			amuletBonus = 65
		end
	end
	
	local rLevelTxt = getText(m_rEditLine)
	local rLevelVal = tonumber(rLevelTxt)
	rLevelVal = CheckPercentVal(rLevelVal, 95, 0, 100, m_rEditLine)
	
	rLevelVal = rLevelVal / 100
	
	--[[local artLevelTxt = getText(m_artEditLine)
	local artLevelVal = tonumber(artLevelTxt)
	artLevelVal = CheckPercentVal(artLevelVal, 5, 0, 10, m_artEditLine)
	local doblestStats = math.floor(872 * GetArtBonus(artLevelVal))]]
	local doblestStats = 500
	
	local useShop = getCheckBoxState(m_shopCheckBox)
	local useOrden = getCheckBoxState(m_ordenCheckBox)
	local useAlhim = getCheckBoxState(m_alhimCheckBox)
	local useDoblest = getCheckBoxState(m_doblestCheckBox)
	local useEatR = getCheckBoxState(m_eatRCheckBox)
	local useGuildCrit = getCheckBoxState(m_guildCritCheckBox)
	local useOrnament = getCheckBoxState(m_ornamentCheckBox)
	local summaStat = currMaster+currResh+currBesp+currCrit+amuletBonus
	if useShop then 
		summaStat = summaStat + 100
	end	
	if useAlhim then
		summaStat = summaStat + 50
	end
	
	local topEquals = {}
	
	local resM, resR, resB, resCrit
	local maxRes = {}
	maxRes.value = 0
	maxRes.m = 0
	maxRes.r = 0
	maxRes.b = 0
	maxRes.crit = 0
	maxRes.doblestType = 0
	
	local step = 20

	for m=amuletBonus, summaStat, step do
		for b=0, summaStat-m, step do
			for crit=0, summaStat-m-b, step do
				resM = m
				resB = b
				resR = summaStat-b-m-crit
				resCrit = crit
				if useDoblest then
					local maxVal = math.max(m, resR, b)
					if m == maxVal then
						resM = m + doblestStats
						maxRes.doblestType = DOBLEST_M
					elseif resR == maxVal then
						resR = resR + doblestStats
						maxRes.doblestType = DOBLEST_R
					else
						resB = b + doblestStats
						maxRes.doblestType = DOBLEST_B
					end
				end
				if useOrden then
					resR = resR + 100
				end
				if useEatR then
					resR = resR + 25
				end
				if useGuildCrit then
					resCrit = crit + 40
				end
				if useOrnament then
					resM = resM + 48
					resCrit = resCrit + 48
				end
				local res = CalcResult(resM, resR, resB, resCrit, rLevelVal, aType, 1000)
				if IsBetterResult(maxRes.value, res, aType) then
					maxRes.value = res
					maxRes.m = resM
					maxRes.r = resR
					maxRes.b = resB
					maxRes.crit = resCrit
					
					topEquals = {}
					table.insert(topEquals, copyTable(maxRes))
				elseif maxRes.value == res then
					table.insert(topEquals, {m=resM, r=resR, b=resB, crit=resCrit, doblestType=maxRes.doblestType})
				end
			end
		end
	end
	
	--LogInfo("topEquals ", GetTableSize(topEquals))
	--тут для одинаковых результатов увеличиваем точность в 1000 раз и считаем снова
	for i = 1, GetTableSize(topEquals) do
		if i==1 then
			maxRes.value = 0
			maxRes.m = 0
			maxRes.r = 0
			maxRes.b = 0
			maxRes.crit = 0
			maxRes.doblestType = 0
		end
		local data = topEquals[i]
		local res = CalcResult(data.m, data.r, data.b, data.crit, rLevelVal, aType, 1000000)
		if IsBetterResult(maxRes.value, res, aType) then
			maxRes.value = res
			maxRes.m = data.m
			maxRes.r = data.r
			maxRes.b = data.b
			maxRes.crit = data.crit
			maxRes.doblestType = data.doblestType
		end
	end

	local currValue = CalcResult(realMaster+amuletBonus, realResh, realBesp, realCrit, rLevelVal, aType, 1000000)	
	local diff = 0
	if aType == KILL_TIME then
		diff = FloorToStep((currValue/maxRes.value-1)*100, 0.001)
	else
		diff = FloorToStep((maxRes.value/currValue-1)*100, 0.001)
	end
	
	if maxRes.doblestType == DOBLEST_M then
		setText(m_mWdg, tostring(math.floor(maxRes.m-amuletBonus-doblestStats)).."+"..tostring(doblestStats))
	else
		setText(m_mWdg, tostring(math.floor(maxRes.m-amuletBonus)))
	end
	if maxRes.doblestType == DOBLEST_R then
		setText(m_rWdg, tostring(math.floor(maxRes.r-doblestStats)).."+"..tostring(doblestStats))
	else
		setText(m_rWdg, tostring(math.floor(maxRes.r)))
	end
	if maxRes.doblestType == DOBLEST_B then
		setText(m_bWdg, tostring(math.floor(maxRes.b-doblestStats)).."+"..tostring(doblestStats))
	else
		setText(m_bWdg, tostring(math.floor(maxRes.b)))
	end
	setText(m_critWdg, tostring(math.floor(maxRes.crit)))
	if diff > 0 then
		setText(m_diffWdg, tostring(diff).."%", "ColorGreen")
	else
		setText(m_diffWdg, tostring(diff).."%", "ColorRed")
	end
	
	
	if amuletBonus > 0 then
		setText(m_amuletInfo, ConcatWString(getLocale()["amuletInfo"], toWString(amuletBonus)), "ColorGray")
	else
		setText(m_amuletInfo, "")
	end
end


function InitConfigForm()
	setTemplateWidget(m_template)
	local formWidth = 500
	local form=createWidget(mainForm, "ConfigForm", "Panel", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, formWidth, 555, 100, 120)
	priority(form, 5500)
	hide(form)
	local grShiftX = 25
	local grShiftY = 140

	local btnWidth = 160
	
	setLocaleText(createWidget(form, "calcButton1", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, btnWidth, 25, 50, 525))
	setLocaleText(createWidget(form, "calcButton2", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, btnWidth, 25, 50, 525))

	local descWdg = createWidget(form, "desc", "TextView", nil, nil, formWidth-25*2, 200, 25, 30)
	setLocaleText(descWdg)
	descWdg:SetMultiline(true)
	
	setLocaleText(createWidget(form, "lineM", "TextView", nil, nil, 600, 25, grShiftX, grShiftY))
	setLocaleText(createWidget(form, "lineR", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30))
	setLocaleText(createWidget(form, "lineB", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*2))
	setLocaleText(createWidget(form, "lineCrit", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*3))
	setLocaleText(createWidget(form, "lineDiff", "TextView", nil, nil, 600, 25, grShiftX, grShiftY+30*5))
	

	m_mWdg = createWidget(form, "resM", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY)
	m_rWdg = createWidget(form, "resR", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30)
	m_bWdg = createWidget(form, "resB", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*2)
	m_critWdg = createWidget(form, "resCrit", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*3)
	m_diffWdg = createWidget(form, "resDiff", "TextView", nil, nil, 600, 25, formWidth/2+100, grShiftY+30*5)
	
	m_amuletInfo = createWidget(form, "amuletInfo", "TextView", nil, nil, formWidth-grShiftX*2, 60, grShiftX, grShiftY+30*3+15)
	m_amuletInfo:SetMultiline(true)
	
	m_guildCritCheckBox = createWidget(form, "useGuildCrit", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 335)
	m_eatRCheckBox = createWidget(form, "useEatR", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 360)
	m_alhimCheckBox = createWidget(form, "useAlhim", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 385)
	m_shopCheckBox = createWidget(form, "useShop", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 410)
	m_ordenCheckBox = createWidget(form, "useOrden", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 435)
	m_doblestCheckBox = createWidget(form, "useDoblest", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 270, 25, 220, 460)
	m_ornamentCheckBox = createWidget(form, "useOrnament", "CheckBox", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 320, 25, 170, 485)
	setCheckBox(m_guildCritCheckBox, false)
	setCheckBox(m_eatRCheckBox, false)
	setCheckBox(m_shopCheckBox, false)
	setCheckBox(m_ordenCheckBox, false)
	setCheckBox(m_alhimCheckBox, false)
	setCheckBox(m_doblestCheckBox, false)
	setCheckBox(m_ornamentCheckBox, false)
	
	local wdg = createWidget(form, "amountOfR", "TextView", nil, nil, 160, 60, grShiftX, 400)
	wdg:SetMultiline(true)
	setLocaleText(wdg)
	m_rEditLine = createWidget(form, "EditLine1", "EditLine", nil, nil, 40, 25, 90, 414, nil, nil)
	setText(m_rEditLine, "95")
	--[[
	wdg = createWidget(form, "lvlOfArt", "TextView", nil, nil, 160, 60, grShiftX, 450)
	wdg:SetMultiline(true)
	setLocaleText(wdg)
	m_artEditLine = createWidget(form, "EditLine2", "EditLine", nil, nil, 40, 25, 90, 464, nil, nil)
	setText(m_artEditLine, "5")
	]]
	setLocaleText(m_guildCritCheckBox)
	setLocaleText(m_eatRCheckBox)
	setLocaleText(m_shopCheckBox)
	setLocaleText(m_ordenCheckBox)
	setLocaleText(m_alhimCheckBox)
	setLocaleText(m_doblestCheckBox)
	setLocaleText(m_ornamentCheckBox)
	setLocaleText(m_mWdg)
	setLocaleText(m_rWdg)
	setLocaleText(m_bWdg)
	setLocaleText(m_critWdg)
	setLocaleText(m_diffWdg)


	setText(createWidget(form, "closeBarsButton", "Button", WIDGET_ALIGN_HIGH, WIDGET_ALIGN_LOW, 20, 20, 20, 14), "x")
	DnD.Init(form, form, true)
	AddReaction("closeBarsButton", function () ChangeMainWndVisible() end)
	
	AddReaction("calcButton1", CalcPressed1)
	AddReaction("calcButton2", CalcPressed2)
	
	return form
end


function Init()
	m_template = getChild(mainForm, "Template")
	setTemplateWidget(m_template)
		
	local button=createWidget(mainForm, "AORBMButton", "Button", WIDGET_ALIGN_LOW, WIDGET_ALIGN_LOW, 50, 25, 300, 120)
	setText(button, "MBR")
	DnD.Init(button, button, true)
	
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