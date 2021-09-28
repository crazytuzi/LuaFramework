-- Filename：	VIPBenefitCell.lua
-- Author：		Fu Qiongqiong
-- Date：		2016-4-7
-- Purpose：		vip每周礼包cell

module("VIPBenefitCell", package.seeall)
require "script/ui/vip_benefit/VIPBenefitData"
require "script/ui/vip_benefit/VIPBenefitController"
require "script/ui/tip/AnimationTip"
local _whiteBg = nil
local _tCellInfo = nil
function createCell(tCellInfo, p_index, p_touchPriority)
	_touchPriorit = p_touchPriority
    _tCellInfo = tCellInfo
	local cell = CCTableViewCell:create()
	--cell背景
	local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
	local bg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
	bg:setPreferredSize(CCSizeMake(635,240))
    bg:setScale(g_fScaleX)
	cell:addChild(bg)
    print("bg:getContentSize().width*MainScene.elementScale",bg:getContentSize().width*MainScene.elementScale)
	-- 标题背景
    local titleBg = CCScale9Sprite:create("images/sign/sign_bottom.png")
    titleBg:setContentSize(CCSizeMake(270,60))
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setScale(1.2)
    titleBg:setPosition(ccp(0,bg:getContentSize().height+10))
    bg:addChild(titleBg)
    local titleBgSize = titleBg:getContentSize()
    -- 标题文本
    local  titleLabel = CCRenderLabel:create(_tCellInfo.des,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    titleLabel:setColor(ccc3(0xff,0xff,0xff))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(titleBgSize.width / 2,titleBgSize.height / 2)
    titleBg:addChild(titleLabel)

    _whiteBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	_whiteBg:setContentSize(CCSizeMake(437,130))
	_whiteBg:setAnchorPoint(ccp(0,1))
	_whiteBg:setPosition(ccp(20,175))
	bg:addChild(_whiteBg)
    createScrollView(_tCellInfo)
    --原价
    local richInfo1 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 20,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = tonumber(_tCellInfo.cost),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2("fqq_070", richInfo1)
    priceLabel:setAnchorPoint(ccp(0, 0))
    priceLabel:setPosition(ccp(bg:getContentSize().width*0.15,bg:getContentSize().height*0.07))
    bg:addChild(priceLabel)

    --现价
    local richInfo2 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 20,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = tonumber(_tCellInfo.discount),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel2 = GetLocalizeLabelSpriteBy_2("fqq_071", richInfo2)
    priceLabel2:setAnchorPoint(ccp(0, 0))
    priceLabel2:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.07))
    bg:addChild(priceLabel2)
    local isRedTip = VIPBenefitData.isRedLine(tonumber(_tCellInfo.discount),tonumber(_tCellInfo.cost))
     --红色的划线
    local noSprite = CCSprite:create("images/recharge/limit_shop/no_more.png")
	noSprite:setAnchorPoint(ccp(0.5,0.5))
	noSprite:setPosition(ccp(priceLabel:getContentSize().width*0.5,priceLabel:getContentSize().height/2))
	priceLabel:addChild(noSprite)
	noSprite:setVisible(isRedTip)

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriorit)
    bg:addChild(menu)
    
    local isCanBuy = VIPBenefitData.isCanBuy(p_index)
    local btn 
    if(isCanBuy)then
        btn = CCSprite:create("images/common/yigoumai.png")
        btn:setScale(1.1)
        btn:setAnchorPoint(ccp(1,0.5))
        btn:setPosition(ccp(bg:getContentSize().width-15,bg:getContentSize().height*0.47))
        bg:addChild(btn)
    else
        --购买按钮
        local normalSprite  = CCSprite:create("images/common/btn/btn_purple2_n.png")
        local selectSprite  = CCSprite:create("images/common/btn/btn_purple2_h.png")
        local disabledSprite = BTGraySprite:create("images/common/btn/btn_purple2_n.png")
        btn = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
        btn:setAnchorPoint(ccp(1,0.5))
        btn:setPosition(ccp(bg:getContentSize().width-15,bg:getContentSize().height*0.5))
        btn:registerScriptTapHandler(buycallBcak)
        menu:addChild(btn,1,tonumber(_tCellInfo.id))
        local des = CCRenderLabel:create(GetLocalizeStringBy("key_1523"),g_sFontPangWa,30,1,ccc3(0x00, 0x00, 0x00),type_stroke)
        des:setColor(ccc3(0xfe, 0xdb, 0x1c))
        des:setAnchorPoint(ccp(0.5,0.5))
        des:setPosition(ccp(btn:getContentSize().width*0.5,btn:getContentSize().height*0.5))
        btn:addChild(des)
    end

    --vip几级可以购买的标注
    local richInfo2 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0x78, 0x25, 0x00),
        labelDefaultFont = g_sFontPangWa,
        labelDefaultSize = 18,
        defaultType = "CCLabelTTF",
        elements = {
            
            {
                text = tonumber(_tCellInfo.id),
                type = "CCLabelTTF",
                color = ccc3( 0x78, 0x25, 0x00),
            }
        }
    }
    local biaozhu = GetLocalizeLabelSpriteBy_2("fqq_069", richInfo2)
    biaozhu:setAnchorPoint(ccp(0.5, 0))
    biaozhu:setPosition(ccp(btn:getContentSize().width*0.5,btn:getContentSize().height*1.1))
    btn:addChild(biaozhu)
    return cell
end
function buycallBcak( tag )
	--判断是否可以购买
	--获取玩家的Vip级别
	local level = UserModel.getVipLevel()
	if(level < tag)then
        AnimationTip.showTip(GetLocalizeStringBy("fqq_068"))
        return
	end
    --判断金币是否足够
    local data = VIPBenefitData.getAllWeekGiftBag()
    local goldnum = data[tonumber(tag)].discount
    if(UserModel.getGoldNumber() < goldnum)then
        AnimationTip.showTip(GetLocalizeStringBy("fqq_078"))
        return
    end
	local showCallfunc = function ( pConfirmed )
        if not pConfirmed then
            return
        end
	   local callback = function ( ... )
		-- body
	   end
	   VIPBenefitController.buyWeekGift(tag,callback)
	end
	
    local richInfo = {
            linespace = 10,
            elements = {
                {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png",
                },
                {
                    text = goldnum,
                },
                
            }
        }
        local newRichInfo = nil
        newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_072"), richInfo)
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, showCallfunc, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)
end
function createScrollView()
    local scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(_whiteBg:getContentSize().width, _whiteBg:getContentSize().height))
    scrollView:setViewSize(CCSizeMake(_whiteBg:getContentSize().width, _whiteBg:getContentSize().height))
    scrollView:ignoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(ccp(0.5,0.5))
    scrollView:setPosition(ccp(_whiteBg:getContentSize().width*0.5,_whiteBg:getContentSize().height *0.5))
    scrollView:setTouchPriority(_touchPriorit)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _whiteBg:addChild(scrollView)
    local data = _tCellInfo.reward
    local dataInfo = string.split(data,",")
    for k,v in pairs(dataInfo) do
        local rewardInDb = ItemUtil.getItemsDataByStr(dataInfo[k])
        local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -400, 800, -640,function ( ... )
    end,nil,nil,false)
    icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,28))
    scrollView:addChild(icon)
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    icon:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setColor(itemColor)
    nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,3)) 
    end 
end