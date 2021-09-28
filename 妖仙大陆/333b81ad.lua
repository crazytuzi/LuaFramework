local _M = { }
_M.__index = _M

local Skill = require "Zeus.Model.Skill"
local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'

local self = {
	menu = nil,
	skillData = nil,
	skillList = nil,
	pos = 0,
	lastDetailPos = 0,
	detail = nil,
}

local RequestDetail

local function GetItemNum(templateId)
	local bag_data = DataMgr.Instance.UserData.RoleBag
	local vItem = bag_data:MergerTemplateItem(templateId)
	local cur_num =(vItem and vItem.Num) or 0
	return cur_num
end

local function RequestItemDetail(sender)
	local templateId = sender.UserData
	
	Util.ShowItemDetailByTempID(templateId)
end

local function SubSplit( str,reps )
    if str == nil  or str == '' then
        return
    end
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

local cellTab = { }
local function CheckAllRedPoint()
    if self.skillList == nil then
        return
    end
    for i = 2, #self.skillList do
        local data = self.skillList[i]
        if data == nil then
            break
        end
        local canUpgrade = true
        
        if data.flag == 0 then
            canUpgrade = false
        end
        
        if data.maxLevel <= data.level then
            canUpgrade = false
        end

        
        local level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
        if level < data.upgradeNeedLevel then
            canUpgrade = false
        end

        
        local skilldata = GlobalHooks.DB.Find('SkillData', data.skillId)
        local costMoney = 0
        if data.level <  data.maxLevel then
            if skilldata ~= nil then
               local costStr = skilldata.UpCostGold 
               for k,v in ipairs(SubSplit(costStr,';')) do 
                    local needLvTab = SubSplit(v,':')
                    if k == data.level +1 then
                        costMoney = tonumber(needLvTab[2])
                    end
                end
            end
        end

        if DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD, 0) < costMoney then
               canUpgrade = false
        end

        if cellTab ~= nil then 
            local cvs_redPoint = cellTab[i-1]:FindChildByEditName("ib_r1", true)
            if canUpgrade == false then
                cvs_redPoint.Visible=false
            else
                cvs_redPoint.Visible=true
            end
        end
    end

end

local function RefreshOneSkill(data)

	if data ~= nil then
        if self.pos ~= nil and cellTab ~= nil then
      	    MenuBaseU.SetVisibleUENode(cellTab[self.pos -1], "tbt_skill1", data.type == 1 or data.type == 3)
		    MenuBaseU.SetVisibleUENode(cellTab[self.pos -1], "tbt_skill2", data.type ~= 1 and data.type ~= 3)
		    MenuBaseU.SetLabelText(cellTab[self.pos -1], "lb_skillname", data.name, 0, 0)
        end
		local lvStr
		local lvColor
		if data.flag == 0 then
			lvStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "lv_open")
			lvStr = string.format(lvStr, data.upgradeNeedLevel)
			lvColor = 0xe7e5d1ff
		else
			lvStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "lv")
			lvStr = string.format(lvStr, data.level)
			lvColor = 0xe7e5d1ff
		end
        if self.pos ~= nil and cellTab ~= nil then
		    MenuBaseU.SetLabelText(cellTab[self.pos -1], "lb_curLv", lvStr, lvColor, 0)
		    MenuBaseU.SetImageBoxFroXmlKey(cellTab[self.pos -1], "ib_skillicon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..data.pic, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
        end
		local lockSelect = data.type ~= 1 or data.flag == 0

		local tbtName =(data.type == 1 or data.type == 3) and "tbt_skill1" or "tbt_skill2"
        if self.pos ~= nil and cellTab ~= nil then
		    MenuBaseU.SetGrayUENode(cellTab[self.pos -1], tbtName, lockSelect)
            MenuBaseU.SetVisibleUENode(cellTab[self.pos -1], "ib_r1", data.canUpgrade[1] == 1)
        end
        
        RequestDetail(data, true)
        if self.skillList ~= nil then
            self.skillList[self.pos] = data
        end



    end
end

local function ActiveTalent(skillId, cvs_frame)
	local data = self.skillList[self.pos]
	Skill.UnlockSkill(skillId, function()
		
		XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("activate")
		
		local effectNode = cvs_frame:FindChildByEditName("ib_activation", true)
		effectNode.Visible = true
		
		
		local control = effectNode.Layout.SpriteController
		control:PlayAnimate(0, 1, function(sender)
			effectNode.Visible = false
		end )
		
		RequestDetail(data, true)
	end )
end














































local function UpgradeSkill(sender)
	local data = self.skillList[self.pos]

	
	if data.maxLevel <= data.level then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "lv_max")
		GameAlertManager.Instance:ShowNotify(tipStr)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
		return
	end

	
	local level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
	if level < data.upgradeNeedLevel then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "lv_ne")
		tipStr = string.format(tipStr, data.upgradeNeedLevel)
		GameAlertManager.Instance:ShowNotify(tipStr)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
		return
	end

	
       local skilldata = GlobalHooks.DB.Find('SkillData', data.skillId)
        local costMoney = 0
        if data.level <  data.maxLevel then
            if skilldata ~= nil then
               local costStr = skilldata.UpCostGold
               for k,v in ipairs(SubSplit(costStr,';')) do 
                   local needLvTab = SubSplit(v,':')
                    if k == data.level +1 then
                        costMoney = tonumber(needLvTab[2])
                    end
                end
            end
        end

		if DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD, 0) < costMoney then
			local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "gold_ne")
			GameAlertManager.Instance:ShowNotify(tipStr)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
			return
		end

    local effNode = self.menu:FindChildByEditName("ib_jinengshengji", true)
  

	Skill.UpgradeSkill(data.skillId, function()
		
		
		
		
		
		
		
		
		
		
		
        Util.showUIEffect(effNode,30) 
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("skillup")
	end )
end

local function SetCostMoney(self, needNum)
	local ib_costnum = self.menu.mRoot:FindChildByEditName("ib_costnum", true)
    ib_costnum.Text = needNum
    local mygold = ItemModel.GetGold()
    ib_costnum.FontColorRGBA =(mygold >= needNum) and 0xffffffff or 0xff0000ff

    CheckAllRedPoint()
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
        if self.needCostNum then
            SetCostMoney(self, self.needCostNum)      
        end
    end
end




local function RefreshDetail(skill,detail)
	
	local basic = skill
	
	self.menu:SetLabelText("lb_skillname", basic.name, 0, 0)
	
	

	
	local lvStr
	local lvColor
	if basic.flag == 0 then
		lvStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "no_control")
		lvColor = 0xff0000ff
	else
		lvStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "current_lv")
		lvStr = string.format(lvStr, basic.level + basic.extlv, basic.maxLevel)
		lvColor = basic.extlv > 0 and 0x00ff00ff or 0xbcb18eff
	end
	self.menu:SetLabelText("lb_skilllv", lvStr, lvColor, 0)

	
	local desc1 = self.menu.mRoot:FindChildByEditName("tb_description", true)
	local db = GlobalHooks.DB.Find('SkillData', basic.skillId)
	if db ~= nil then
		local descStr = "<a>" .. db.SkillDesc .. "</a>"
		desc1.XmlText = Skill.DescFormat(descStr, detail.curDesData)

	end

	local secondStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "second")
	
	local nonStr = '-'
	
	local cdStr = detail.colddown ~= 0 and(detail.colddown / 1000) .. secondStr or nonStr
	local costStr = detail.curManaCost ~= 0 and tostring(detail.curManaCost) or nonStr
	self.menu:SetLabelText("lb_cdbnum", cdStr, 0, 0)
	self.menu:SetLabelText("lb_manacostbnum", costStr, 0, 0)

	
	local needlvStr = basic.upgradeNeedLevel ~= -1 and tostring(basic.upgradeNeedLevel) or nonStr
	local color = basic.upgradeNeedLevel > DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0) and 0xff0000ff or 0xe7e5d1ff
	self.menu:SetLabelText("lb_needlv", needlvStr, color, 0)
	local needlvLabel = self.menu.mRoot:FindChildByEditName("lb_renwulv", true)
	color = basic.upgradeNeedLevel > DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0) and 0xff0000ff or 0xd8c793ff
	MenuBaseU.SetLabelText(needlvLabel, needlvLabel.Text, color, 0)

	
    local costMoney = 0
    if basic.level <  basic.maxLevel then
        if db ~= nil then
           local costStr = db.UpCostGold 
           for k,v in ipairs(SubSplit(costStr,';')) do 
                local needLvTab = SubSplit(v,':')
                if k == basic.level +1 then
                    costMoney = tonumber(needLvTab[2])
                end
            end
        end
    end


    local ib_costnum = self.menu.mRoot:FindChildByEditName("ib_costnum", true)
    ib_costnum.Text = costMoney
    ib_costnum.FontColorRGBA =(DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD, 0) >= costMoney) and 0xffffffff or 0xff0000ff

    if basic.level >= basic.maxLevel then 
         ib_costnum.Text = nonStr
    end

    self.needCostNum = costMoney
    
    local upgradeBtn = self.menu.mRoot:FindChildByEditName("btn_upskill", true)
    if upgradeBtn ~= nil then
        upgradeBtn.TouchClick = UpgradeSkill
        local canUpgrade = true
        local btStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "upskill")
        if basic.flag == 0 then
            canUpgrade = false
        else
            
            if basic.maxLevel <= basic.level then
                btStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "max_lv")
                canUpgrade = false
            end

            
            local level = DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
            if level < basic.upgradeNeedLevel then
                canUpgrade = false
            end
            
            if DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD, 0) < costMoney then
                    canUpgrade = false
            end
         end
		
		MenuBaseU.SetButtonText(upgradeBtn, btStr, 0, 0)
		
		
		
		

		
		
		self.menu:SetVisibleUENode("ib_r2", detail.canUpgrade == 1 and canUpgrade)
	end
    CheckAllRedPoint()
end

RequestDetail = function(skill, isForceReq)
	Skill.GetSkillDetail(skill, isForceReq, function(detail)
		self.detail = detail
		RefreshDetail(skill,detail)
	end )
end

local function SaveShortcut()
	
	local savedata = { }
	for i = 1, 5 do
		local iconBox = self.menu:GetComponent("cvs_bar" .. i)
		if iconBox ~= nil then
			local data = { }
			data.keyPos = i
			data.skillId = iconBox.UserTag
			savedata[i] = data
		end
	end
	Skill.RequestSaveShortcut(savedata)
end

local function ShowShortcutEffect(isShow)
	for i = 1, 5 do
		local cvs_bar = self.menu:GetComponent("cvs_bar" .. i)
		MenuBaseU.SetVisibleUENode(cvs_bar, "ib_bareffect", isShow)
	end
end

local function RefreshShowShortcutSelect()
	if self.skillList == nil then
		return
	end
	local skillId = self.skillList[self.pos].skillId
	for i = 1, 5 do
		local cvs_bar = self.menu:GetComponent("cvs_bar" .. i)
		if cvs_bar ~= nil then
			MenuBaseU.SetVisibleUENode(cvs_bar, "ib_bareffect", cvs_bar.UserTag == skillId)
			if cvs_bar.UserTag > 0 and tonumber(cvs_bar.UserData) == 0 then
				MenuBaseU.SetVisibleUENode(cvs_bar, "ib_closet", true)
				MenuBaseU.SetVisibleUENode(cvs_bar, "lb_level_request", true)
			else
				MenuBaseU.SetVisibleUENode(cvs_bar, "ib_closet", false)
				MenuBaseU.SetVisibleUENode(cvs_bar, "lb_level_request", false)
			end
		end
	end
end

local function findSkillData(skillId)
	for k, v in pairs(self.skillList) do
		if v.skillId == skillId then
			return v
		end
	end
end

local function EquipShortcut(sender)
	if sender.UserTag > 0 and tonumber(sender.UserData) == 0 then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "unlock_self")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end

	if self.pos == 0 then
		return
	end
	
	if self.pos == 1 then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "no_quick")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end
	local data = self.skillList[self.pos]
	
	if data.type ~= 1 then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "no_quick")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end
	
	if data.flag == 0 then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "skill_ne")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end

	local oldd = findSkillData(sender.UserTag)
	local shortcut = Skill.GetShortcut()
	for i = 1, shortcut.Count - 1 do
		local iconBox = self.menu:GetComponent("cvs_bar" .. i)
		if iconBox ~= nil and iconBox.UserTag == data.skillId then
			
			MenuBaseU.SetImageBoxFroXmlKey(iconBox, "ib_skillicon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..oldd.pic, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
			iconBox.UserTag = sender.UserTag
			break
		end
	end
	MenuBaseU.SetImageBoxFroXmlKey(sender, "ib_skillicon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..data.pic, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
	sender.UserTag = data.skillId
	sender.UserData = tostring(data.flag)
    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
	RefreshShowShortcutSelect()

end

local function IsEquipShortcut(skillid)
	local shortcut = Skill.GetShortcut()
	for i = 1, shortcut.Count - 1 do
		local iconBox = self.menu:GetComponent("cvs_bar" .. i)
		if iconBox ~= nil and iconBox.UserTag == skillid then
			return true
		end
	end
	return false
end

local function InitShortcut()
	ShowShortcutEffect(false)
	local shortcut = Skill.GetShortcut()
	if shortcut.Count <= 0 then
		return
	end

	local cvs_bar = self.menu.mRoot:FindChildByEditName("cvs_keyb", true)
	
	for i = 1, shortcut.Count - 1 do
		local skill = shortcut[i].Data
		local iconBox = cvs_bar:FindChildByEditName("cvs_bar" .. skill.keyPos, true)
		if iconBox ~= nil then
			local imgPath = skill.icon == "" and "" or "static_n/actskill_icon/" .. skill.icon .. ".png"
			MenuBaseU.SetImageBoxFroXmlKey(iconBox, "ib_skillicon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..skill.icon, LayoutStyle.IMAGE_STYLE_BACK_4, 8)

			iconBox.TouchClick = EquipShortcut
			iconBox.UserTag = skill.baseSkillId
			iconBox.UserData = tostring(skill.flag)

			MenuBaseU.SetVisibleUENode(iconBox, "ib_closet", false)
			MenuBaseU.SetVisibleUENode(iconBox, "lb_level_request", false)
			MenuBaseU.SetVisibleUENode(iconBox, "ib_bareffect", true)
		end
	end
	RefreshShowShortcutSelect();
end


local function OnSkillSelected(sender)
	local index = sender.UserTag
	local data = self.skillList[index]
	self.pos = index
	self.pan:RefreshShowCell()
	RequestDetail(data, false)
	RefreshShowShortcutSelect()
    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")

end

local function CellRefresh(x, y, cell)
	
	local index = y + 1 + 1
	local data = self.skillList[index]
	cell.Visible = data ~= nil
	if data ~= nil then
		MenuBaseU.SetVisibleUENode(cell, "tbt_skill1", data.type == 1 or data.type == 3)
		MenuBaseU.SetVisibleUENode(cell, "tbt_skill2", data.type ~= 1 and data.type ~= 3)
		MenuBaseU.SetLabelText(cell, "lb_skillname", data.name, 0, 0)
		local lvStr
		local lvColor
		if data.flag == 0 then
			lvStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "lv_open")
			lvStr = string.format(lvStr, data.upgradeNeedLevel)
			lvColor = 0xe7e5d1ff
		else
			lvStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "lv")
			lvStr = string.format(lvStr, data.level)
			lvColor = 0xe7e5d1ff
		end
		MenuBaseU.SetLabelText(cell, "lb_curLv", lvStr, lvColor, 0)
		MenuBaseU.SetImageBoxFroXmlKey(cell, "ib_skillicon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..data.pic, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		local lockSelect = data.type ~= 1 or data.flag == 0

		local tbtName =(data.type == 1 or data.type == 3) and "tbt_skill1" or "tbt_skill2"
		MenuBaseU.SetGrayUENode(cell, tbtName, lockSelect)
		

        MenuBaseU.SetVisibleUENode(cell, "ib_r1", data.canUpgrade[1] == 1)
        
     
        local tbt = cell:FindChildByEditName(tbtName, true)
        tbt.UserTag = index
        tbt.IsChecked = self.pos == index
        

        local selectImg = cell:FindChildByEditName("img_select", true)
        if selectImg then
            selectImg.Visible = self.pos == index
        end
    end
end

local cellIndex = 0
local function CellInit(cell)
	
	local tbt1 = cell:FindChildByEditName("tbt_skill1", true)
	tbt1.TouchClick = OnSkillSelected
	local tbt2 = cell:FindChildByEditName("tbt_skill2", true)
	tbt2.TouchClick = OnSkillSelected
    cellIndex = cellIndex + 1
    cellTab[cellIndex] = cell
end

local function SelectByPos(pos)
	self.pos = pos
	self.pan:RefreshShowCell()
	if pos > 0 and pos <= #self.skillList then
		RequestDetail(self.skillList[pos], false)
		RefreshShowShortcutSelect()
	end
end

local function ShowShortcutUI(sender)
	
	if not Skill.CanShortcut() then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "unlock_all")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end

	local data = self.skillList[self.pos]

	
	if data.type ~= 1 then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "no_quick")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end

	
	if data.flag == 0 then
		local tipStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.SKILL, "skill_ne")
		GameAlertManager.Instance:ShowNotify(tipStr)
		return
	end

	self.lastDetailPos = self.pos
	self.menu:SetVisibleUENode("cvs_setup", true)
	SelectByPos(self.pos)
	
end
local function InitList(cb)
	
	
	
    cellIndex = 0
	Skill.GetSkillList( function(skilldata)
		
		self.skillData = skilldata
		self.skillList = skilldata.skillList
		
		if self.skillList == nil then
			return
		end
         
		
		self.pos = 2
		self.pan = self.menu.mRoot:FindChildByEditName("sp_see", true)
		local cell = self.menu.mRoot:FindChildByEditName("cvs_list", true)
		cell.Visible = false




		self.pan:Initialize(
		cell.Width + 32,
		cell.Height + 0,
		#self.skillList - 1,
		
		1,
		
		cell,
		CellRefresh,
		CellInit
		)
		self.menu:SetVisibleUENode("cvs_setup", false)
		self.effectFlag = nil
		cb()
	end , function()
		
	end )
end

local function OnExit()
	DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter1)
	DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter2)
    DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)





    self.menu.Visible = false
end

local function OnEnter()
	
	InitShortcut()

	DataMgr.Instance.UserData.RoleBag:AddFilter(self.filter1)
	DataMgr.Instance.UserData.RoleBag:AddFilter(self.filter2)
    DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag, self)
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
end

local function OnLoad(self, callBack)

	
	InitList( function()
		
		callBack:DynamicInvoke()
		SelectByPos(2)
        self.menu.Visible = true
	end )
end

local function InitCompnent()
	

	
	local backBtn = self.menu.mRoot:FindChildByEditName("btn_back", true)
	if backBtn ~= nil then
		backBtn.TouchClick = function(sender)
			SaveShortcut()
			self.menu:Close()
		end
	end

	
	local closeBtn = self.menu.mRoot:FindChildByEditName("btn_close", true)
	if closeBtn ~= nil then
		closeBtn.TouchClick = function(sender)
			SaveShortcut()
			
			self.menu:Close()
              EventManager.Fire("Event.FuncEntryMenu.SkillRedPoint", {})
		end
	end

	
	local oneKeyUpLevBtn = self.menu.mRoot:FindChildByEditName("oneKeyUpLev", true)
	if oneKeyUpLevBtn ~= nil then
		oneKeyUpLevBtn.TouchClick = function(sender)

            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
			Skill.UpgradeSkillOneKey(function(skillList)
            self.skillList = skillList
            if self.skillList == nil then
                return
            end
				
				local effNode = self.menu:FindChildByEditName("ib_jinengshengji", true)
                Util.showUIEffect(effNode,30) 
                XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("skillup")
				
				
				
				
				
				
				
				
				



		            RequestDetail(self.skillList[self.pos], true)  
                    if self.pan ~= nil then
		               self.pan:RefreshShowCell()
                   end        
			end )
		end
	end

	
	Skill.AddSkillChangeListener("allSkill", RefreshOneSkill)
	Skill.AddSPChangeListener("skillsp", function(changeSp)
		
		self.menu:SetLabelText("cvs_pointnum", tostring(changeSp), 0, 0)
	end )
	Skill.AddShortcutListener("shortcut", function()
		
		InitShortcut()
	end )
    self.menu.Visible = false
	self.menu:SubscribOnLoad( function(callback)
		OnLoad(self, callback)
	end )
	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory( function()
		
		Skill.RemoveSkillChangeListener("allSkill")
		Skill.RemoveSPChangeListener("skillsp")
		Skill.RemoveShortcutListener("shortcut")

		self = nil
	end )

	self.filter1 = ItemPack.FilterInfo.New()
	self.filter2 = ItemPack.FilterInfo.New()
end

local function Init()
	self.menu = LuaMenuU.Create("xmds_ui/skill/skill_main.gui.xml", GlobalHooks.UITAG.GameUISkillMain)
    self.menu.ShowType = UIShowType.HideBackHud
	InitCompnent()
	return self.menu
end

local function Create()
	self = { }
	setmetatable(self, _M)
	Init()
	return self
end

return { Create = Create }
