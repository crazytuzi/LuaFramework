--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-10-13
--

local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")
local CommonEquipInfoLayer = class("CommonEquipInfoLayer", function()
    return require("utility.ShadeLayer").new()
end)

function CommonEquipInfoLayer:initSuit()
    -- 初始化套装列表
    self.suitInfo = require("game.Equip.EquipSuitInfo").new({
        curId = self.resId
        })
    self.suitInfo:setAnchorPoint(0.5,1)
    self._rootnode["taozhuang_node"]:addChild(self.suitInfo)

    local maxOff = 470 + self.suitInfo:getHeight()
    self.scrollBg:setContentSize(CCSize(display.width, maxOff))
    self.scrollBg:setContentOffset(ccp(0,-150), false)
    self.contentContainer:setPosition(display.width/2,maxOff)

end

function CommonEquipInfoLayer:ctor(param,infoType)
    self:setNodeEventEnabled(true)
    local _info     = param.info
    local _subIndex = param.subIndex
    local _index    = param.index
    local _listener = param.listener
    local _bEnemy   = param.bEnemy
    local _closeListener = param.closeListener

    local _baseInfo = data_item_item[_info.resId]

    local boardSize = nil

    if _baseInfo.Suit == nil then
        boardSize = CCSize(640,620)
    else
        boardSize = CCSize(display.width,850)
    end

    self._proxy = CCBProxy:create()
    self._rootnode = {}

    local bgNode = CCBuilderReaderLoad("equip/equip_comon_info.ccbi", self._proxy, self._rootnode,self,boardSize)
    bgNode:setPosition(display.cx, display.cy - bgNode:getContentSize().height / 2)
    self:addChild(bgNode, 1)



    local coProxy = CCBProxy:create()
    self.contentContainer = CCBuilderReaderLoad("equip/equip_comon_content.ccbi", coProxy, self._rootnode, self, CCSizeMake(640, 620)) 

    self.contentNode = display.newNode()
    self.contentNode:addChild(self.contentContainer)  
    self.contentNode:setPosition(display.width/2,0)  

    self.scrollBg = CCScrollView:create()
    bgNode:addChild(self.scrollBg)

    self.scrollBg:setContainer(self.contentNode)
    self.scrollBg:setPosition(0,80)
    self.scrollBg:setViewSize(CCSize(display.width, boardSize.height - 150))
    local maxOff = 800
    self.scrollBg:setContentSize(CCSize(display.width, maxOff))
    self.scrollBg:setDirection(kCCScrollViewDirectionVertical)
    self.scrollBg:setContentOffset(ccp(0,-maxOff/2+55), false)
    self.scrollBg:ignoreAnchorPointForPosition(true)
    self.scrollBg:updateInset()
    self.contentContainer:setPosition(display.width/2,maxOff)
    self._rootnode["titleLabel"]:setString("装备信息")

    
    self.resId = _info.resId

    self.baseInfo = _baseInfo

    local isSuit = _baseInfo.Suit
    if isSuit == nil then --不是套装
        self.scrollBg:setTouchEnabled(false)
    else
        --是套装，做一定的处理
        self.scrollBg:setTouchEnabled(true)
        -- self._rootnode["common_base_node"]:setContentSize(display.width,display.height)
        self:initSuit()
    end
    --  星级
--    dump(_info)
    for i = 1, _info.star do
        self._rootnode[string.format("star%d", i)]:setVisible(true)
    end

    --  大图标
    local path = ResMgr.getLargeImage( _baseInfo.bicon, ResMgr.EQUIP )
    self._rootnode["skillImage"]:setDisplayFrame(display.newSprite(path):getDisplayFrame())

    --是否是从阵容进来的？如果不是阵容进来的，则隐藏“更换”和“卸下”按钮
    if infoType == 2 then
        self._rootnode["changeBtn"]:setVisible(false)
        self._rootnode["takeOffBtn"]:setVisible(false)
--        self._rootnode["xiLianBtn"]:setVisible(false)
--        self._rootnode["qiangHuBtn"]:setPositionX(display.width/2)
    end

    self._rootnode["closeBtn"]:setVisible(true)
    self._rootnode["closeBtn"]:addHandleOfControlEvent(function()
        if _closeListener then
            _closeListener()
        end
        self:removeSelf()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end, CCControlEventTouchUpInside)

    local function change()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        CCDirector:sharedDirector():popToRootScene()
        push_scene(require("game.form.EquipChooseScene").new({
            index = _index,
            subIndex = _subIndex,
            cid      = _info.cid,
            callback = function(data)
                if data then
                    _listener(data)
                end
                self:removeSelf()
            end
        }))
    end

    local function takeOff()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        RequestHelper.formation.putOnEquip({
            pos = _index,
            subpos = _subIndex,
            callback = function(data)
                -- dump(data)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else
                    _info.pos = 0
                    _info.cid = 0
                    if _listener then
                        _listener(data)
                    end
                    self:removeSelf()
                end
            end
        })
    end

    local function refresh()

        self._rootnode["tag_card_bg"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. _info.star .. ".png"):getDisplayFrame())
        --  基本属性
        local index = 1

        for k, v in ipairs(_info.base) do
            if self._rootnode["basePropLabel_" .. tostring(k)] then
                self._rootnode["basePropLabel_" .. tostring(k)]:setString("")
            end
            local nature = data_item_nature[EQUIP_BASE_PROP_MAPPPING[k]]
            if v > 0 then
                local str = nature.nature
                if nature.type == 1 then
                    str = str .. string.format(": +%d", v)
                else
                    str = str .. string.format(": +%d%%", v / 10)
                end
                self._rootnode["basePropLabel_" .. tostring(index)]:setString(str)
                index = index + 1
            end
        end
        self._rootnode["curLvLabel"]:setString(_info.level)
    end

    local function qiangHua() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhuangBei_QiangHua, game.player:getLevel(), game.player:getVip()) 
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        if not bHasOpen then
            show_tip_label(prompt)
        else
            self._rootnode["qiangHuBtn"]:setEnabled(false)
            local layer = require("game.Equip.FormEquipQHLayer").new({
                info = _info,
                listener = function()
                    refresh()
                    _listener()
                    self:removeSelf()
                end
            })
            self:setVisible(false)
            game.runningScene:addChild(layer, 11)
        end
    end

    local function xiLian() 
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiLian, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt)
        else
            local layer = require("game.Equip.FormEquipXiLianLayer").new({
                info = _info,
                listener = function()
                    refresh()
                    _listener()
                    self:removeSelf()
                end
            })
            self:setVisible(false)
            game.runningScene:addChild(layer, 11)
        end
    end

    local nameLabel = ui.newTTFLabelWithShadow({
        text = _baseInfo.name,
        font = FONTS_NAME.font_haibao,
        size = 30,
        align = ui.TEXT_ALIGN_CENTER
    })
    self._rootnode["itemNameLabel"]:addChild(nameLabel)
    nameLabel:setColor(NAME_COLOR[_baseInfo.quality])

    self._rootnode["descLabel"]:setString(_baseInfo.describe)

    self._rootnode["cardName"]:setString(_baseInfo.name)

    self._rootnode["changeBtn"]:addHandleOfControlEvent(change, CCControlEventTouchDown)
    self._rootnode["takeOffBtn"]:addHandleOfControlEvent(takeOff, CCControlEventTouchDown)
    self._rootnode["qiangHuBtn"]:addHandleOfControlEvent(qiangHua, CCControlEventTouchUpInside)

    if _baseInfo.polish == 1 then
        self._rootnode["xiLianBtn"]:addHandleOfControlEvent(xiLian, CCControlEventTouchUpInside)
    else
        self._rootnode["xiLianBtn"]:setVisible(false)
    end

    if _bEnemy then
        self._rootnode["changeBtn"]:setVisible(false)
        self._rootnode["xiLianBtn"]:setVisible(false)
        self._rootnode["takeOffBtn"]:setVisible(false)
        self._rootnode["qiangHuBtn"]:setVisible(false)
    end

    refresh()
end

function CommonEquipInfoLayer:onEnter()
    TutoMgr.addBtn("equip_info_qianghua_btn", self._rootnode["qiangHuBtn"])
    TutoMgr.active()
end


function CommonEquipInfoLayer:onExit()
    TutoMgr.removeBtn("equip_info_qianghua_btn")
end


return CommonEquipInfoLayer



