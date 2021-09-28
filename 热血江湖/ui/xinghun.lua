-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_xinghun = i3k_class("wnd_xinghun", ui.wnd_base)

local multiplyIcon = 8481 --十连图片
function wnd_xinghun:ctor()
	self.isMulti = false
	self._isPlayed = false
	self._isCanClick = true
	self.co = nil
end

function wnd_xinghun:configure()
    local ui = self._layout.vars
    self.ui = ui

    local roleType = g_i3k_game_context:GetRoleType()
    local bwType = g_i3k_game_context:GetTransformBWtype()

    self.starConfig = i3k_db_chuanjiabao.star[roleType]

    ui.close:onClick(self, self.onCloseUI)

    local content = require("ui/widgets/" .. self.starConfig.ui)()
    self.contentRoot = content.rootVar
    self.contentAnis = content.anis
    self.contentUI = content.vars

    ui.email_info:addChild(content)

    ui.guide_btn:onClick(self, self.onStarSpiritBtn)

    ui.changeBtn:onClick(self, self.onChangeBtn)

    ui.upStageBtn:onClick(
        self,
        function()
            g_i3k_ui_mgr:OpenUI(eUIID_XingHunUpStage)
            g_i3k_ui_mgr:RefreshUI(eUIID_XingHunUpStage)
            if g_i3k_game_context:xingHunIsShowRedPoint() then
                g_i3k_game_context:resetXinghunRedPoint(false)
                self.ui.upStageRedPoint:setVisible(g_i3k_game_context:xingHunIsShowRedPoint())
            end
        end
    )

    ui.helpBtn:onClick(
        self,
        function()
            g_i3k_ui_mgr:ShowHelp(i3k_get_string(16955))
        end
    )
	self._starIcons = {8478, 8479, 8480} --星级对应的图片id
end

function wnd_xinghun:refresh()
    local starSpirit = g_i3k_game_context:getHeirloomData().starSpirit

    local mainStarShowLevel = i3k_db_chuanjiabao.cfg.showNeedStage
    local mainStarUnlockLevel = i3k_db_chuanjiabao.cfg.unlockNeedStage

    local isShowMainStar = starSpirit.rank >= mainStarShowLevel
    local isUnLockMainStar = starSpirit.rank >= mainStarUnlockLevel

    self.contentUI.mainStar:setVisible(isShowMainStar)
    self.contentUI.mainIcon:setVisible(isUnLockMainStar)
    self.contentUI.mainIconBg:setImage(g_i3k_db.i3k_db_get_icon_path(isUnLockMainStar and 5350 or 5351))

    local roleType = g_i3k_game_context:GetRoleType()
    local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(roleType, starSpirit.mainStarLvl)
    if cfg then
        self.contentUI.mainIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
    end

    self.contentUI.mainBtn:onClick(
        self,
        function()
            if isUnLockMainStar then
                g_i3k_ui_mgr:OpenUI(eUIID_XingHunMainStarPractice)
                g_i3k_ui_mgr:RefreshUI(eUIID_XingHunMainStarPractice)
            elseif isShowMainStar then
                g_i3k_ui_mgr:OpenUI(eUIID_XingHunMainStarLock)
                g_i3k_ui_mgr:RefreshUI(eUIID_XingHunMainStarLock)
            else
                g_i3k_ui_mgr:PopupTipMessage("未开启")
            end
        end
    )

    self.contentUI.rank:setText(starSpirit.rank .. "阶")
    self.contentUI.mainInfo:setText(starSpirit.mainStarLvl .. "级")

    local function contrlSubStar(index, isShow)
        self.contentUI["icon" .. index]:setVisible(isShow)
        self.contentUI["info" .. index]:setVisible(isShow)
        self.contentUI["lock" .. index]:setVisible(not isShow)
        self.contentUI["process" .. index]:setVisible(isShow)
    end

    for index, subStarId in ipairs(self.starConfig.subStars) do
        local itemData = starSpirit.miniStars[subStarId]
        if itemData then
            contrlSubStar(index, true)
            self.contentUI["info" .. index]:setText(itemData.level .. "/" .. g_i3k_db.xinghun_getSubStarMaxLevel())
            local subStarConfig = g_i3k_db.xinghun_getSubStarConfig(subStarId, itemData.level + 1)
            local percent = subStarConfig and (itemData.exp / subStarConfig.exp) * 100 or 0
            self.contentUI["process" .. index]:setPercent(percent)

            self.contentUI["btn" .. index]:onClick(
                self,
                function()
                    if itemData.level >= i3k_db_chuanjiabao.starStage[#i3k_db_chuanjiabao.starStage].subStarLevelLimit then
                        --副星圆满
                        g_i3k_ui_mgr:OpenUI(eUIID_XingHunSubStarPerfect)
                        g_i3k_ui_mgr:RefreshUI(eUIID_XingHunSubStarPerfect, subStarId, itemData.level)
                    else
                        --副星详情
                        g_i3k_ui_mgr:OpenUI(eUIID_XingHunSubStar)
                        g_i3k_ui_mgr:RefreshUI(
                            eUIID_XingHunSubStar,
                            subStarId,
                            itemData.level,
                            itemData.exp,
                            subStarConfig and subStarConfig.exp or nil
                        )
                    end
                end
            )
        else
            contrlSubStar(index, false)
            self.contentUI["btn" .. index]:onClick(
                self,
                function()
                    g_i3k_ui_mgr:OpenUI(eUIID_XingHunSubStarLock)
                    g_i3k_ui_mgr:RefreshUI(eUIID_XingHunSubStarLock, subStarId)
                end
            )
        end
    end
	self:setBtnIcon()

    self:refreshCost()

    self.ui.upStageRedPoint:setVisible(g_i3k_game_context:xingHunIsShowRedPoint())
end

function wnd_xinghun:choseSubStar(id)
    local _id = 0
    for i, v in ipairs(self.starConfig.subStars) do
        if v == id then
            _id = i
        end
    end
    return _id
end

function wnd_xinghun:playExpAni(id, exp)
    local _id = self:choseSubStar(id)
    if _id ~= 0 then
        self.contentUI["expLable" .. _id]:setText("+" .. exp)
        self.contentAnis["sj" .. _id].play()
        local icon = self.contentUI["icon" .. _id]
        local startPosItem = self.contentUI.startPos
        local startPos = startPosItem:getPosition()
        local endPos = self.contentRoot:convertToNodeSpace(icon:convertToWorldSpace(icon:getPosition()))
        local fire = require("ui/widgets/lizi")()
        self.contentRoot:addChild(fire)
        fire.rootVar:setPosition(startPos)
        fire.rootVar:runAction(
            cc.Sequence:create(
                cc.MoveTo:create(0.8, cc.p(endPos.x,endPos.y)),
                cc.CallFunc:create(
                    function()
                        self.contentRoot:removeChild(fire)
                    end
                )
            )
        )
    end
end

function wnd_xinghun:playLevelUpAni(id)
    local _id = self:choseSubStar(id)
    if _id ~= 0 then
        if self.contentAnis["c_js" .. _id] then
            self.contentAnis["c_js" .. _id].play()
        end
    end
end

function wnd_xinghun:playUnloclAni(id)
    local _id = self:choseSubStar(id)
    if _id ~= 0 then
        if self.contentAnis["c_sj" .. _id] then
            self.contentAnis["c_sj" .. _id].play()
        end
    end
end

function wnd_xinghun:playUnlockMainStarAni()
    local aniName = "c_sj10"
    if self.contentAnis[aniName] then
        self.contentAnis[aniName].play()
    end
end

function wnd_xinghun:refreshCost()
    self.ui.costScroll:removeAllChildren()

    local guideStarConfig
    if self.isMulti then
        guideStarConfig = i3k_db_chuanjiabao.cfg.continueConsumes
    else
        guideStarConfig = i3k_db_chuanjiabao.cfg.consumes
    end
    self.isEnoughguideCost = true
    for k, v in ipairs(guideStarConfig) do
        if v.id ~= 0 then
            local item = require("ui/widgets/shenqixinghunt")()

            item.vars.pet_iconBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
            item.vars.play_btn:onClick(
                self,
                function()
                    g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
                end
            )
            item.vars.pet_icon:setImage(
                g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole())
            )
            item.vars.start_icon:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))

            local haveCnt = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
            if v.id == g_BASE_ITEM_COIN then
                item.vars.pet_power:setText(v.count)
            else
                item.vars.pet_power:setText(haveCnt .. "/" .. v.count)
            end
            if haveCnt < v.count then
                self.isEnoughguideCost = false
            end
            item.vars.pet_power:setTextColor(haveCnt >= v.count and g_i3k_get_hl_green_color() or g_i3k_get_hl_red_color())

            self.ui.costScroll:addItem(item)
        end
    end
end

function wnd_xinghun:onStarSpiritBtn(sender)
	if self._isCanClick then
		if self._isPlayed then
			self.isMulti = not self.isMulti
			self:setBtnIcon()
			self:refreshCost()
			self._layout.anis.c_qie1.play()
			self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
				self._isCanClick = false
				g_i3k_coroutine_mgr.WaitForSeconds(0.2)
				self._isCanClick = true
			end)
		else
			if not self.isEnoughguideCost then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
				return
			end
			if g_i3k_game_context:GetXingHunSubStatNotFullExpNum() == g_i3k_game_context:GetCurSubStarCnt() then
				g_i3k_ui_mgr:PopupTipMessage("当前辅星已满级")
				return
			end
			i3k_sbean.request_star_spirit_operate_req(self.isMulti and 1 or 0)
		end
	end
end
function wnd_xinghun:onChangeBtn(sender)
	if self._isCanClick then
		if not self._isPlayed then
			self._isPlayed = true
			self.isMulti = not self.isMulti
			self:setBtnIcon()
			self:refreshCost()
			self._layout.anis.c_qie1.play()
			self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
				self._isCanClick = false
				g_i3k_coroutine_mgr.WaitForSeconds(0.2)
				self._isCanClick = true
			end)
		else
			if not self.isEnoughguideCost then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
				return
			end
			if g_i3k_game_context:GetXingHunSubStatNotFullExpNum() == g_i3k_game_context:GetCurSubStarCnt() then
				g_i3k_ui_mgr:PopupTipMessage("当前辅星已满级")
				return
			end
			i3k_sbean.request_star_spirit_operate_req(self.isMulti and 1 or 0)
		end
	end
end
function wnd_xinghun:setBtnIcon()
	local starSpirit = g_i3k_game_context:getHeirloomData().starSpirit
	local guideNum = i3k_db_chuanjiabao.starStage[starSpirit.rank].guideStarNum
	if not self._isPlayed then
		if self.isMulti then
			self._layout.vars.guide_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(multiplyIcon))
			self._layout.vars.changeBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(self._starIcons[guideNum]))
		else
			self._layout.vars.changeBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(multiplyIcon))
			self._layout.vars.guide_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(self._starIcons[guideNum]))
		end
	else
		if self.isMulti then
			self._layout.vars.changeBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(multiplyIcon))
			self._layout.vars.guide_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(self._starIcons[guideNum]))
		else
			self._layout.vars.guide_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(multiplyIcon))
			self._layout.vars.changeBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(self._starIcons[guideNum]))
		end
	end
end
function wnd_xinghun:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self.co)
end
function wnd_create(layout, ...)
    local wnd = wnd_xinghun.new()
    wnd:create(layout, ...)
    return wnd
end
