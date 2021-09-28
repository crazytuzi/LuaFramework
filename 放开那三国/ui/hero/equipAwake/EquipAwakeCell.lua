-- Filename: EquipAwakeCell.lua
-- Author: FQQ
-- Date: 2016-01-05
-- Purpose:装备觉醒物品展示cell

module ("EquipAwakeCell",package.seeall)
require "db/DB_Awake_ability"

function createCell( p_cellInfo, p_index, p_touch)
	local tCell = CCTableViewCell:create()
	--背景
	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(630,165))
 	tCell:addChild(cellBackground)
	-- 小背景
 	local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
 	textBg:setContentSize(CCSizeMake(376, 100))
 	textBg:setAnchorPoint(ccp(0,0))
 	textBg:setPosition(ccp(120, 20))
 	cellBackground:addChild(textBg)

 	--添加觉醒背景
 	local awake = CCSprite:create("images/hero/info/awake.png")
 	textBg:addChild(awake)
 	awake:setAnchorPoint(ccp(0,0.5))
 	awake:setPosition(ccp(15,textBg:getContentSize().height*0.5))

 	local awakeLabel = CCLabelTTF:create(GetLocalizeStringBy("fqq_053"),g_sFontName,25)
   	awakeLabel:setColor(ccc3(0xff,0xff,0xff))
   	awakeLabel:setAnchorPoint(ccp(0.5,0.5))
   	awakeLabel:setPosition(ccp(awake:getContentSize().width*0.5,awake:getContentSize().height*0.5))
   	awake:addChild(awakeLabel)

 	 local icon = CCSprite:create("images/common/border.png")
    cellBackground:addChild(icon)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(ccp(20,cellBackground:getContentSize().height*0.5))
 	--通过id读表获取装备信息
 	local equipId = p_cellInfo.EquipId
 	local info = DB_Awake_ability.getDataById(equipId)
 	--物品名称
 	local name = info.name
 	local nameLabel = CCRenderLabel:create(name, g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    nameLabel:setPosition(ccp(cellBackground:getContentSize().width*0.2,cellBackground:getContentSize().height*0.9))
    nameLabel:setColor(ccc3(0xe4,0x00,0xff))
    cellBackground:addChild(nameLabel)
 	--物品描述
 	local desc = info.des 
 	local descLabel = CCLabelTTF:create(desc,g_sFontName,21,CCSizeMake(300,80),kCCTextAlignmentLeft)
 	descLabel:setAnchorPoint(ccp(0,0.5))
    descLabel:setPosition(ccp(textBg:getContentSize().width*0.18,textBg:getContentSize().height*0.5))
    descLabel:setColor(ccc3(0x78,0x25,0x00))
    textBg:addChild(descLabel)

    local icon1 = info.icon or " "
    --物品的icon
    local iconString = "images/athena/awake_icon/"..icon1
    --物品的icon
    local iconSprite = CCSprite:create(iconString)
    iconSprite:setAnchorPoint(ccp(0.5,0.5))
    iconSprite:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
    icon:addChild(iconSprite)

 	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	cellBackground:addChild(buyMenuBar)

	--装备觉醒
	local changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_045"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	changeBtn:setAnchorPoint(ccp(1, 0.5))
	changeBtn:setPosition(ccp(cellBackground:getPositionX()+cellBackground:getContentSize().width - 7*g_fScaleX, cellBackground:getContentSize().height*0.5))
	changeBtn:registerScriptTapHandler(changeAction)
	buyMenuBar:addChild(changeBtn, 1, tonumber(equipId))
	return tCell
end
--替换装备
function changeAction( tag, item  )
	 --音效
     AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local equipId = tag
	local index = EquipAwakeLayer.getIndex()
	local callBack = function ( ... )
		--刷新tableview中的显示
		EquipAwakeLayer.updateUI()
	end
	EquipAwakeController.activeMasterTalent(index,equipId,callBack)
end



