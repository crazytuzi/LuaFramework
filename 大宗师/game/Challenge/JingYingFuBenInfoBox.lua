 --[[
 --
 -- @authors shan 
 -- @date    2014-06-03 17:40:45
 -- @version 
 --
 --]]

require("game.GameConst")
local data_item_item = require("data.data_item_item")
local data_jingyingfuben_jingyingfuben =  require("data.data_jingyingfuben_jingyingfuben")


local JingYingFuBenInfoBox = class("JingYingFuBenInfoBox", function (data) 
	return require("utility.ShadeLayer").new()
end)

function JingYingFuBenInfoBox:onExit()
    -- self.removeFunc()
    TutoMgr.removeBtn("jingying_infobox_zhandou")
end

function JingYingFuBenInfoBox:onEnter()
    local tutoBtn =self._rootnode["to_battle_btn"]
    
    TutoMgr.addBtn("jingying_infobox_zhandou",tutoBtn)
    TutoMgr.active()
end

function JingYingFuBenInfoBox:ctor(index,removeFunc)
    self.removeFunc = removeFunc
    display.addSpriteFramesWithFile("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")

    self.index = index
    self:setNodeEventEnabled(true)
    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}

    self._rootnode = {}
    local node = CCBuilderReaderLoad("ccbi/challenge/jingying_fuben_infoBox.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node)


     local fireEff = ResMgr.createArma({
            resType = ResMgr.UI_EFFECT,
            armaName = "jingyingguankajiemiantexiao",
            isRetain = true
        })
     -- fireEff:setAnchorPoint()
     fireEff:setPosition(self._rootnode["upper_node"]:getContentSize().width/2,0)

    self._rootnode["upper_node"]:addChild(fireEff)
    

    setControlBtnEvent(self._rootnode["backBtn"],function()
        self.removeFunc()
        self:removeSelf()
        end,
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            end)



    setControlBtnEvent(self._rootnode["to_battle_btn"],function()        
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
       GameStateManager:ChangeState(GAME_STATE.STATE_JINGYING_BATTLE,self.index)
        end,
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        end)
    
    local fubenData = data_jingyingfuben_jingyingfuben[index]
    local name = fubenData.name
    local bossIcon = fubenData.boss
    local itemIcons = fubenData.arr_icon
    local silver = fubenData.silver
    local xiahun = fubenData.xiahun

    self._rootnode["label_silver"]:setString(silver)
    self._rootnode["label_xiahun"]:setString(xiahun)

    self.guanKaName = ui.newTTFLabelWithOutline({
            text = name,
            size = 30,
            color = ccc3(255,239,166),
            outlineColor = ccc3(161,53,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
    self._rootnode["fuben_title"]:setVisible(false)

    self.guanKaName:setPosition(self._rootnode["fuben_title"]:getPositionX(),self._rootnode["fuben_title"]:getPositionY())
    self._rootnode["upper_node"]:addChild(self.guanKaName)

    local bossIconPath = "hero/icon/"..bossIcon..".png"
    local bossSprite = display.newSprite(bossIconPath)
    self._rootnode["boss_icon"]:setDisplayFrame(bossSprite:getDisplayFrame()) 

    for i = 1, 15 do 
        if i > #itemIcons then
            self._rootnode["reward_icon_"..i]:setVisible(false)
            self._rootnode["reward_name_"..i]:setVisible(false)
        else
            self._rootnode["reward_icon_"..i]:setVisible(true)
            self._rootnode["reward_name_"..i]:setVisible(true)
            local resId = itemIcons[i] 
            local itemData = data_item_item[resId]
            if itemData == nil then 
                dump(resId) 
            else
                local curType = ResMgr.getItemTypeByResId(resId)
                local itemIcon = self._rootnode["reward_icon_"..i] 
                ResMgr.refreshIcon({itemBg = itemIcon, id = resId, resType = curType})
                -- print("curType")
                --  ResMgr.refreshItemWithTagNumName({
                --                     itemType = ResMgr.itemType,
                --                     id       = resId,                                    
                --                     itemBg   = itemIcon
                --                     })


                -- ResMgr.refreshItemName({label=self._rootnode["reward_name_"..i],resId = resId})
                local nameColor = ccc3(255, 255, 255)
                if curType == ResMgr.ITEM or curType == ResMgr.EQUIP then 
                    nameColor = ResMgr.getItemNameColor(resId)
                elseif curType == ResMgr.HERO then 
                    nameColor = ResMgr.getHeroNameColor(resId)
                end

                local nameLbl = ui.newTTFLabelWithShadow({
                    text = itemData.name,
                    size = 20,
                    color = nameColor,
                    shadowColor = ccc3(0,0,0),
                    font = FONTS_NAME.font_fzcy,
                    align = ui.TEXT_ALIGN_CENTER 
                    })
                
                nameLbl:setPosition(0, 0)
                self._rootnode["reward_name_"..i]:removeAllChildren()
                self._rootnode["reward_name_"..i]:addChild(nameLbl)

                if itemData.type == 3 then 
                    -- 装备碎片
                    local suipianIcon = display.newSprite("#sx_suipian.png")
                    suipianIcon:setRotation(-15)
                    suipianIcon:setAnchorPoint(ccp(0, 1))
                    suipianIcon:setPosition(-0.13 * itemIcon:getContentSize().width, 0.9 * itemIcon:getContentSize().height)
                    itemIcon:addChild(suipianIcon) 

                elseif itemData.type == 5 then 
                    -- 残魂(武将碎片) 
                    local canhunIcon = display.newSprite("#sx_canhun.png")
                    canhunIcon:setRotation(-18)
                    canhunIcon:setAnchorPoint(ccp(0, 1))
                    canhunIcon:setPosition(-0.13 * itemIcon:getContentSize().width, 0.93 * itemIcon:getContentSize().height)
                    itemIcon:addChild(canhunIcon) 
                end 
            end 

        end
    end

    
end









return JingYingFuBenInfoBox