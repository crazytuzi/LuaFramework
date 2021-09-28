local single = require "ui.singletondialog"
local msitemid = 38609
local FactionXiulian = {}
setmetatable(FactionXiulian, single)
FactionXiulian.__index = FactionXiulian

local function getAllID(tt)
	local idvec = {}
	for k,v in pairs(tt.m_cache) do
		table.insert(idvec, k)
	end
	table.sort(idvec, function(v1, v2) 
		return v1 < v2
	end)
	return idvec
end

function FactionXiulian.new()
	local self = {}
	setmetatable(self, FactionXiulian)
	function self.GetLayoutFileName()
		return "discipline.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pSkills = {}
	for i = 0 , 8 do
		local foo = {}
		foo.icon = CEGUI.toSkillBox(winMgr:getWindow("discipline/commoncase/left/skillbox" .. i))
		foo.icon:subscribeEvent("MouseClick", FactionXiulian.HandleSkillClicked, self)	
		foo.name =  winMgr:getWindow("discipline/commoncase/left/text" .. i)
		self.m_pSkills[i+1] = foo 
	end


	self.curSkill = {}
	self.curSkill.icon = CEGUI.toSkillBox(winMgr:getWindow("discipline/commoncase/right/button"))
	self.curSkill.name =  winMgr:getWindow("discipline/commoncase/right/tittle")
	self.curSkill.describe =  winMgr:getWindow("discipline/commoncase/right/tittletext")
	self.curSkill.enhanceNum =  winMgr:getWindow("discipline/commoncase/right/commoncase/text2")
	self.curSkill.nextEnhanceNum =  winMgr:getWindow("discipline/commoncase/right/commoncase1/text2")
	self.curSkill.memberLevel =  winMgr:getWindow("discipline/commoncase/right/text1")
	self.curSkill.denominatorLevel =  winMgr:getWindow("discipline/commoncase/right/text3")
	self.curSkill.progress =  CEGUI.Window.toProgressBar(winMgr:getWindow("discipline/commoncase/right/case/bar"))
	self.curSkill.curMoney1 =  winMgr:getWindow("discipline/commoncase/right/down/text0")
	self.curSkill.curMoney10 =  winMgr:getWindow("discipline/commoncase/right/down/text1")
	
	self.practice1 = CEGUI.Window.toPushButton(winMgr:getWindow("discipline/commoncase/right/down/button0"))
	self.practice10 = CEGUI.Window.toPushButton(winMgr:getWindow("discipline/commoncase/right/down/button1"))

	self.miCan = {}
	self.miCan.left = winMgr:getWindow("discipline/commoncase/right/down/text3")
	self.miCan.practice = CEGUI.Window.toPushButton(winMgr:getWindow("discipline/commoncase/right/down/button2"))
	self.miCan.leftTitle = winMgr:getWindow("discipline/commoncase/right/down/text2")

	self.hightLight = winMgr:getWindow("discipline/commoncase/left/imageliang")


	self.practice1:setID(1)
	self.practice10:setID(10)
	self.practice1:subscribeEvent("Clicked",FactionXiulian.HandleBtnClicked,self)
	self.practice10:subscribeEvent("Clicked",FactionXiulian.HandleBtnClicked,self)
	self.miCan.practice:subscribeEvent("Clicked",FactionXiulian.HandleBtnClickedMiCan,self)


	self.zhanDouXiuLian = CEGUI.Window.toGroupButton(winMgr:getWindow("discipline/button"))
	self.shuXingXiuLian = CEGUI.Window.toGroupButton(winMgr:getWindow("discipline/button0"))

	self.zhanDouXiuLian:subscribeEvent("SelectStateChanged",FactionXiulian.HandleBtnClickedZhanDouXiuLian,self)
	self.shuXingXiuLian:subscribeEvent("SelectStateChanged",FactionXiulian.HandleBtnClickedShuXingXiuLian,self)

	self.m_pContribute = winMgr:getWindow("discipline/text1") 
	self.m_pContribute:setText(0)
    self.m_pContributeTitle =  winMgr:getWindow("discipline/text0")

	local itemnum = GetRoleItemManager():GetItemNumByBaseID(msitemid)
	self.miCan.left:setText(itemnum)

	self.m_hLuaItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(FactionXiulian.OnItemNumberChange) --mican
	self.m_hPackMoneyChange = GetRoleItemManager().EventPackMoneyChange:InsertScriptFunctor(FactionXiulian.RefreshMoney)	

	self.m_pEffectWnd1 = winMgr:getWindow("discipline/effect0")
	self.m_pEffectWnd2 = winMgr:getWindow("discipline/effect1")

	self:ShowTab(1)

	self.zhanDouXiuLian:setSelected(true)

		
	return self
end




function FactionXiulian:OnClose()
	GetRoleItemManager().EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
	GetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hLuaItemNumChangeNotify)
	single.OnClose(self)
end

function FactionXiulian:ContributeVisible(bool)
	self.m_pContribute:setVisible(bool)
    self.m_pContributeTitle:setVisible(bool)
end


function FactionXiulian:showQuickBuyDlg()
	local itemid = 38349
	if GetChatManager() then
		GetChatManager():AddTipsMsg(146320)
    end
	local ybnum = GetDataManager():GetYuanBaoNumber()
	if ybnum >= 600 then
		itemid = 38771
	elseif ybnum >= 100 then
		itemid = 38350
	elseif ybnum < 10 then
		return false
	end
	CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
	return true
end


function FactionXiulian:HandleBtnClicked(e)
	local id = CEGUI.toWindowEventArgs(e).window:getID()
	if id == 0 then 
		return
	end
	local money = GetRoleItemManager():GetPackMoney()
	local typeid = id==10 and 10 or 1
	self.update = id
	if self.tabID == 1 then	
		if money >= 25000 * typeid then
			GetNetConnection():send(knight.gsp.skill.CUpdaetAssistSkillLevel(self.npckey or 0,self.config.id*typeid))
		else 
			self:showQuickBuyDlg()
		end
	elseif self.tabID == 2 then
		if money >= 50000 * typeid then
			local p = require "protocoldef.knight.gsp.faction.enhance.cenhanceattr" :new()
			p.opertype = id == 10 and 10 or 1
			p.attrid = self.config.id
			require("manager.luaprotocolmanager"):send(p)
		else
			self:showQuickBuyDlg()
		end
	end	
end


function FactionXiulian:HandleBtnClickedMiCan(e)
	local pitem = GetRoleItemManager():GetItemByBaseID(msitemid)
	if pitem then
		GetRoleItemManager():UseItem(pitem)
        self.update = 1
	end
	local itemnum = GetRoleItemManager():GetItemNumByBaseID(msitemid)
	if itemnum == 0 then
		GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145782).msg)
	end
end

function FactionXiulian:HandleBtnClickedZhanDouXiuLian(e)
	self:setMiCanVisible(true)
	self:ShowTab(1)
end

function FactionXiulian:HandleBtnClickedShuXingXiuLian(e)
	self:setMiCanVisible(false)
	self:ShowTab(2)
end

function FactionXiulian:setMiCanVisible(v)
	self.miCan.left:setVisible(v)
	self.miCan.practice:setVisible(v)
	self.miCan.leftTitle:setVisible(v) 
end



function FactionXiulian:HandleSkillClicked(args)
	LogInsane("HandleSkillClicked")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if id == 0 then 
		return
	end
	local e = CEGUI.toMouseEventArgs(args)
	local pt = e.position
--	CSkillBoxControl:HandleShowSkilltips(id, -1)
	self:ShowSelectItem(id)

	return true
end

function FactionXiulian:ShowTab(id)
	local tableName
	if id == 1 then
		tableName = "knight.gsp.game.claoxiulian"
        self:ContributeVisible(true)
	elseif id == 2 then
		tableName = "knight.gsp.game.cxinxiulian"
        self:ContributeVisible(false)
	else
		return
	end
	self.tabID = id
	local tt = BeanConfigManager.getInstance():GetTableByName(tableName)
	local ids 
	if tt then
		ids = getAllID(tt)
		for i = 1, 9 do
			self.m_pSkills[i].name:setText("")
			self.m_pSkills[i].icon:SetImage(nil)
			self.m_pSkills[i].icon:setID(0)
			self.m_pSkills[i].icon:setVisible(false)
			self.m_pSkills[i].name:setVisible(false)
			if ids[i] then
				self.m_pSkills[i].icon:setVisible(true)
				self.m_pSkills[i].name:setVisible(true)
				local cfg = require "utils.mhsdutils".getLuaBean(tableName, ids[i])
				self.m_pSkills[i].name:setText(cfg.name)
				self.m_pSkills[i].icon:SetBackgroundDynamic(true)
				self.m_pSkills[i].icon:setID(ids[i])
				if id == 1 then
					CSkillBoxControl:GetInstance():SetSkillInfo(self.m_pSkills[i].icon, cfg.id, 0)
					self:SetBackgroundIcon(GetRoleSkillManager():GetLifeSkillLevel(cfg.id),self.m_pSkills[i].icon)
				elseif id == 2 then
					self.m_pSkills[i].icon:SetImage(GetIconManager():GetImageByID(cfg.tubiaoid))
					self:SetBackgroundIcon(self.serverData and self.serverData[cfg.id] and self.serverData[cfg.id].level  ,self.m_pSkills[i].icon)
				end

			end
		end
		self.config = require "utils.mhsdutils".getLuaBean(tableName, ids[1])
		self:ShowSelectItem(ids[1])
	end
end

function FactionXiulian:ShowSelectItem(id)
	if not id then
		return
	end
	if self.tabID == 2 then
		if not self.serverData then
			return
		else
			tableName = "knight.gsp.game.cxinxiulian"
		end
	elseif self.tabID == 1 then
		tableName = "knight.gsp.game.claoxiulian"
	end

	self.config = require "utils.mhsdutils".getLuaBean(tableName, id)
	self.curSkill.icon:SetBackgroundDynamic(true)

	self.curSkill.name:setText(self.config.name)  
	self.curSkill.describe:setText(self.config.shuxingname)
	self:RefreshSkillMaxLevels()
	self:RefreshMoney()

	if self.tabID == 1 then
		self.curSkill.icon:SetImage(GetIconManager():GetImageByID(GetRoleSkillManager():GetSkillIconByID(id)))
		self:UpdateProgress()
	elseif  self.tabID == 2  then
		self.curSkill.icon:SetImage(GetIconManager():GetImageByID(self.config.tubiaoid))
		self:UpdateProgress(self.serverData[id] and self.serverData[id].exp)
	end
	
	
	

end



function FactionXiulian:RefreshMoney()
	if not self then
		self = FactionXiulian:getInstanceOrNot()
		if not self then
			return
		end
	end
	local money = GetRoleItemManager():GetPackMoney()
	local cfg = {}
	if self.tabID == 1 then
		cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cxiulianxiangmu", self.config.id)
	elseif self.tabID == 2 then
		cfg.yinliang = 50000
	else
		return
	end
	
	self.curSkill.curMoney1:setText(cfg.yinliang)
	self.curSkill.curMoney1:setProperty("TextColours", money >= cfg.yinliang and "FFFFFFFF" or "FFFF0000")
	local s10 = cfg.yinliang * 10
	self.curSkill.curMoney10:setText(s10)
	self.curSkill.curMoney10:setProperty("TextColours", money >= s10 and "FFFFFFFF" or "FFFF0000")

end



function FactionXiulian.OnItemNumberChange(bagid, itemkey, itembaseid)
	local self = FactionXiulian:getInstanceOrNot()
	if not self then
		return
	end
	if itembaseid == msitemid then
		local itemnum = GetRoleItemManager():GetItemNumByBaseID(itembaseid)
		self.miCan.left:setText(itemnum)


        local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.claoxiulian")
        local ids = getAllID(tt)
        for i = 1, 9 do
            local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.claoxiulian", ids[i])
            if cfg then
            	self:SetBackgroundIcon(GetRoleSkillManager():GetLifeSkillLevel(cfg.id),self.m_pSkills[i].icon)
        	end
        end


	end
end

function FactionXiulian:UpdateAssistSkill(id, level, exp)
	if not self.update or self.update == 0 or id ~= self.config.id then
		return 
	end
	local dlg = require "ui.faction.factionxiulian":getInstanceOrNot()
	if dlg then
		local oldlevel = self.curLevel or 0
		local oldexp = self.curProgress or 0
		local levelup = false
		if level > oldlevel then
			levelup = true
		end
		
		local hideexp = 0
		for i = oldlevel , level - 1 do
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cxiuliantiaojian", i)
			if cfg then
				hideexp = hideexp + cfg.xuyaojindu
			end
		end
		local addexp = exp + hideexp - oldexp
		local baoji = false
		if (self.update == 1 and addexp ~= 5) or 
			(self.update == 10 and addexp ~= 50) then
			baoji = true
		end
		local effect
		if levelup then
			effect = GetGameUIManager():AddUIEffect(self.m_pEffectWnd1, MHSD_UTILS.get_effectpath(10380), false)
		end
		if baoji and self.tabID == 1 then
			if effect then
		    	local notify = CGameUImanager:createNotify(self.OnEffectEnd)
		       	effect:AddNotify(notify)
			else
				GetGameUIManager():AddUIEffect(self.m_pEffectWnd2, MHSD_UTILS.get_effectpath(10392), false)
			end
		end
	end

	self:SetLevel(level)
	self:RefreshMoney()
	self:UpdateProgress(exp)
	self.update = 0
end
function FactionXiulian.OnEffectEnd()
	local dlg = require "ui.faction.factionxiulian":getInstanceOrNot()
	if not dlg then
		return
	end
	GetGameUIManager():AddUIEffect(dlg.m_pEffectWnd2, MHSD_UTILS.get_effectpath(10392), false)
end

function FactionXiulian:UpdateProgress(progress)
	self.curProgress = progress or GetRoleSkillManager():GetLifeSkillProficiency(self.config.id) or 0
	self.MaxProgress = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cxiuliantiaojian", self.curLevel and (self.curLevel == 0 and 1 or self.curLevel) or 1) 
	self.MaxProgress = self.MaxProgress.xuyaojindu
	self.curSkill.progress:setProgress(self.curProgress/self.MaxProgress)
	self.curSkill.progress:setText(self.curProgress.."/"..self.MaxProgress)
end


function FactionXiulian:RefreshSkillMaxLevels()
	local datamanager = require "ui.faction.factiondatamanager"
	if  datamanager.maxlevels and self.tabID == 1 then
		for k, v in pairs(datamanager.maxlevels) do
			if self.config.id == k then
				self.maxLevel = v
				break
			end
		end	
	elseif self.tabID == 2 then
		self.maxLevel = self.serverData.maxlevel
	end
	self:SetLevel()
end

function FactionXiulian:SetLevel(level)
	local curlevel
	if self.tabID == 1 then
		curlevel = level or GetRoleSkillManager():GetLifeSkillLevel(self.config.id)
	elseif self.tabID == 2 then
		curlevel = level or (self.serverData[self.config.id] and self.serverData[self.config.id].level) or 0 
	end
	self.curLevel = curlevel

	self:SetSelectBackground()
	self.curSkill.memberLevel:setText(self.curLevel)
	self.curSkill.denominatorLevel:setText(self.maxLevel)
	self.curSkill.enhanceNum:setText(self.config.level[self.curLevel-1]) 

	if curlevel == 0 then
		self.curSkill.enhanceNum:setText("0")
	else
		self.curSkill.enhanceNum:setText(self.config.level[self.curLevel-1]) 
	end

	if self.curLevel and self.maxLevel  and self.curLevel >= self.maxLevel then
		self.curSkill.nextEnhanceNum:setText(require("utils.mhsdutils").get_resstring(2484))
	else
		self.curSkill.nextEnhanceNum:setText(self.config.level[self.curLevel]) 
	end
end

function FactionXiulian:SetSelectBackground()
	self:SetBackgroundIcon(self.curLevel,self.curSkill.icon)
	for i = 1 , 9 do
		if self.m_pSkills[i].icon:getID() == self.config.id then
			self:SetBackgroundIcon(self.curLevel,self.m_pSkills[i].icon)
			local pos = self.m_pSkills[i].icon:getPosition()
			self.hightLight:setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale, pos.x.offset+6),CEGUI.UDim(pos.y.scale, pos.y.offset+6))) 
			break
		end
	end
end

function FactionXiulian:SetBackgroundIcon(level,skillIcon)
	if not level or level == 0 then
		local bkimageset = CEGUI.String("BaseControl1")
		local bkimage = CEGUI.String("SkillInCell1")
		skillIcon:SetBackGroundImage(bkimageset, bkimage)
	else
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cxiuliantiaojian", level)
		if cfg then
			cfg = cfg.yansekuang
			local bkimageset = CEGUI.String("BaseControl"..(math.floor((cfg-1)/4)+1))
			local bkimage = CEGUI.String("SkillInCell"..cfg)
			skillIcon:SetBackGroundImage(bkimageset, bkimage)
		end
	end

end

function FactionXiulian:RequestAttri(ty,id)
	if ty == 1 then
		local p = require("protocoldef.knight.gsp.faction.enhance.cgetallenhanceattr"):new() 
		p.attrid = self.config.id
		require("manager.luaprotocolmanager"):send(p)
	else
		require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.faction.enhance.cgetallenhanceattr"):new())
	end
end

function FactionXiulian:Process(attrs,maxlevel)
	self.serverData = {}
	for i = 1 ,#attrs do
		self.serverData[attrs[i].attrid] = attrs[i]		
	end
	self.serverData.maxlevel = maxlevel
end

function FactionXiulian:OneAttrProcess(attrid,level,exp)
	if not self.serverData[attrid] then
		self.serverData[attrid] = {}
	end
	self.serverData[attrid].attrid = attrid
	self.serverData[attrid].level = level
	self.serverData[attrid].exp = exp
end

return FactionXiulian
