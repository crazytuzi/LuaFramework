--[[
******帮派公告、宣言编辑界面*******

	-- by quanhuan
	-- 2015/10/28
]]


local FationLevelUp = class("FationLevelUp",BaseLayer)

function FationLevelUp:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionLevelUplayer")
end

function FationLevelUp:setLevel(oldLevel, newLevel)
	self.oldLevel = oldLevel
	self.newLevel = newLevel
	local factionInfo = FactionManager:getFactionInfo() or {}
	local bannerId = factionInfo.bannerId or '1_1_1_1'
	local bannerInfo = stringToNumberTable(bannerId, '_')
    self.bg_qizhi:setTexture(FactionManager:getBannerBgPath(bannerInfo[1], bannerInfo[2]))
    self.imgIcon:setTexture(FactionManager:getBannerIconPath(bannerInfo[3], bannerInfo[4]))    
end

function FationLevelUp:initUI( ui )

	self.super.initUI(self, ui)

	-- 新功能开发
	self.img_lv = TFDirector:getChildByPath(ui, "img_lv")
	self.img_jn = TFDirector:getChildByPath(ui, "img_jn")
	self.img_ry = TFDirector:getChildByPath(ui, "img_ry2")
	self.img_gn = TFDirector:getChildByPath(ui, "img_gn")
	self.img_xljn = TFDirector:getChildByPath(ui, "img_ry")

	self.txt_FationLevel_old = TFDirector:getChildByPath(self.img_lv, "txt_old")
	self.txt_FationLevel_new = TFDirector:getChildByPath(self.img_lv, "txt_new")

	self.txt_SkillNum_old = TFDirector:getChildByPath(self.img_jn, "txt_old")
	self.txt_SkillNum_new = TFDirector:getChildByPath(self.img_jn, "txt_new")

	self.txt_SkillNum_old_ex = TFDirector:getChildByPath(self.img_xljn, "txt_old")
	self.txt_SkillNum_new_ex = TFDirector:getChildByPath(self.img_xljn, "txt_new")

	self.txt_MemberNum_old = TFDirector:getChildByPath(self.img_ry, "txt_old")
	self.txt_MemberNum_new = TFDirector:getChildByPath(self.img_ry, "txt_new")

	self.bg_qizhi = TFDirector:getChildByPath(ui, "bg_qizhi")
	self.imgIcon = TFDirector:getChildByPath(ui, "img_qi")

	self.txt_open = TFDirector:getChildByPath(self.img_gn, "txt_new")

	self.btn_close = TFDirector:getChildByPath(ui, "btn_close")

	local resPath = "effect/ui/level_up_light.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("level_up_light_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(480+30,800))
    self:addChild(effect,98)
    effect:playByIndex(0, -1, -1, 1)
end

function FationLevelUp:removeUI()
	self.super.removeUI(self)
end

function FationLevelUp:registerEvents()
	self.super.registerEvents(self)
    
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
end

function FationLevelUp:removeEvents()
    self.super.removeEvents(self)

end

function FationLevelUp:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function FationLevelUp:refreshUI()
	play_lingdaolitisheng()

	local GuildData = require('lua.table.t_s_guild_rule')             --vip配置表

	local oldData = GuildData:objectByID(self.oldLevel)
	local newData = GuildData:objectByID(self.newLevel)
	print("elf.newLevel = ",self.newLevel)

	local openfuncitonStr = newData.Architecture

	self.txt_FationLevel_old:setText(self.oldLevel)
	self.txt_FationLevel_new:setText(self.newLevel)

	self.txt_SkillNum_old:setText(oldData.max_skill_level)
	self.txt_SkillNum_new:setText(newData.max_skill_level)

	self.txt_MemberNum_old:setText(oldData.max_member_num)
	self.txt_MemberNum_new:setText(newData.max_member_num)

	self.txt_SkillNum_old_ex:setText(oldData.max_skill_level2)
	self.txt_SkillNum_new_ex:setText(newData.max_skill_level2)
		print("openfuncitonStr = ", openfuncitonStr)
	if openfuncitonStr == "" then
		-- self.img_gn:setVisible(false)
		--self.txt_open:setText("暂无")
		self.txt_open:setText(localizable.common_nono)
	else
		local opendesArr = string.split(openfuncitonStr,'|')
		self.img_gn:setVisible(true)
		local num = #opendesArr
		if num < 1 then
			self.img_gn:setVisible(false)
		else
			local openStr = ""
	        for i=1,num do
	        	openStr = openStr .. opendesArr[i] .. " "
	        end

	        self.txt_open:setText(openStr)
		end
	end
	self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()

        local resPath = "effect/role_starup1.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("role_starup1_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(480,320))
        effect:setScale(0.8)
        self:addChild(effect,4)        
        effect:playByIndex(0, -1, -1, 0)

	end)
	self.ui:runAnimation("Action0",1)
end

-- for test
-- local layer =  AlertManager:addLayerByFile("lua.logic.faction.FationLevelUp", AlertManager.BLOCK_AND_GRAY)
-- layer:setLevel(1, 2)
-- AlertManager:show()

return FationLevelUp