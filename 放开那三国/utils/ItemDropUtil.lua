-- Filename：	ItemDropUtil.lua
-- Author：		zhz
-- Date：		2013-9-25
-- Purpose：		物品掉落的处理信息和现实页面

module("ItemDropUtil" , package.seeall)
require "script/utils/GoodTableView"
require "script/model/user/UserModel"
require "db/DB_Heroes"

-- 将后端传的 drop 表进行处理
--[[ 
'drop':array                                掉落信息
         {
             'item'    =>    array
                     {
                         itemTemplateId => itemNum    物品模板id和数量
                     }
             'hero'    =>    array
                     {
                         heroTid => heroNum            武将模板id和数量
                     }
             'silver'  =>    $dropSilver                银币数量
             treasFrag =>array
	             {
		TreasFragTmpl
	             }
	         }

         items= {
		item = {
			type = "", 
			name=,
			tid=,
			num=,
			}
			....
			


		}
         }
]]
-- 返回一个 可以直接使用 itemTableView 的表
require "db/DB_Heroes"
require "db/DB_Item_hero_fragment"
function getDropItem( drop  )

	local items = {}
	print(" the drop is ;   ===== ")
	print_t(drop)
	-- drop 掉落表
	-- silver 
	if( drop.silver) then
		for k,v in pairs(drop.silver) do
			local item = {}
			item.type = "silver"
			item.num = v
			item.name = GetLocalizeStringBy("key_2889") .. v
			table.insert(items, item)
		end
	end
	-- gold 
	if(drop.gold ) then
		local item = {}
		item.type = "gold"
		item.num = drop.gold
		item.name = GetLocalizeStringBy("key_1443") .. item.num
		table.insert(items,item)
	end
	if( not table.isEmpty(drop.item)) then
	 for k,v in  pairs(drop.item) do
			local item = {}
			item.tid  = k
			item.num = v
			item.type = "item"
			item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
			table.insert(items, item)
		end
	end
	if( not table.isEmpty(drop.hero)) then
		for k ,v in pairs(drop.hero) do
			local item ={}
			item.tid = k
			item.num = v
			item.type = "hero"
			item.name =  DB_Heroes.getDataById(item.tid).name
			table.insert(items,item)
		end
	end
	if( drop.soul) then
		for k,v in pairs(drop.soul) do
			local item = {}
			item.type = "soul"
			item.num = v
			item.name = GetLocalizeStringBy("key_1603") .. v
			table.insert(items, item)
		end
	end
	-- 宝物碎片
	if(not table.isEmpty(drop.treasFrag)) then
		for k,v in pairs(drop.treasFrag) do
			local item = {}
			item.tid = k
			item.num = v
			item.type = "item"
			item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
			table.insert(items,item)
		end
	end
	-- 宠物 add by chengliang
	-- if(not table.isEmpty(drop.pet))then
	-- 	for k,v in pairs(drop.pet) do
	-- 		local item = {}
	-- 		item.tid = v.pet_tmpl
	-- 		item.num = 1
	-- 		item.type = "pet"
	-- 		item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
	-- 		table.insert(items,item)
	-- 	end
	-- end
	return items
end

 --1、银币,2、将魂,3、金币,4、体力,5、耐力,6、物品,7、多个物品,8、等级*银币,9、等级*将魂 ,10 、武将, 11 ,  12,
 -- 处理等级礼包 签到 和
function showGiftLayer(all_good  )
    
    local items = {}
    for i=1, #all_good do
    	local item= {}
    	local goodType = tonumber(all_good[i].reward_type) 
    	if(goodType ==1) then
    		-- local item = {}
			item.type = "silver"
			item.num = all_good[i].reward_values
			item.name = GetLocalizeStringBy("key_2889") .. all_good[i].reward_values
			table.insert(items, item)
    	elseif(goodType == 2) then
    		-- local item = {}
			item.type = "soul"
			item.num = all_good[i].reward_values
			item.name = GetLocalizeStringBy("key_1603") .. all_good[i].reward_values
			table.insert(items, item)
    	elseif(goodType == 3) then
    		item.type = "gold"
			item.num = all_good[i].reward_values
			item.name = GetLocalizeStringBy("key_1443") .. all_good[i].reward_values
			table.insert(items, item)
		elseif(goodType == 4) then
			item.type = "execution"
			item.num = all_good[i].reward_values
			item.name = GetLocalizeStringBy("key_3162") .. all_good[i].reward_values
			table.insert(items, item)
		elseif(goodType == 5) then
			item.type = "stamina"
			item.num = all_good[i].reward_values
			item.name = GetLocalizeStringBy("key_2996") .. all_good[i].reward_values
			table.insert(items, item)
		elseif(goodType == 6) then
			item.tid = all_good[i].reward_ID
			item.num = all_good[i].reward_values
			item.type = "item"
			item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
			table.insert(items,item)
		elseif(goodType== 7) then
			item.tid = all_good[i].reward_ID
			item.num = all_good[i].reward_values
			item.type = "item"
			item.name = ItemUtil.getItemById(tonumber(item.tid)).name 
			table.insert(items,item)
		elseif(goodType == 8) then
			item.type = "silver"
			item.num = all_good[i].reward_values*UserModel.getHeroLevel()
			item.name = GetLocalizeStringBy("key_2889") .. all_good[i].reward_values
			table.insert(items, item)
		elseif(goodType== 9) then
			item.type = "soul"
			item.num = all_good[i].reward_values*UserModel.getHeroLevel()
			item.name = GetLocalizeStringBy("key_2889") .. all_good[i].reward_values
			table.insert(items, item)
		elseif(goodType == 10) then
			item.type = "hero"
			item.tid = all_good[i].reward_ID
			item.num = all_good[i].reward_values
			item.name =  DB_Heroes.getDataById(item.tid).name
			table.insert(items,item)
		end
    end
    require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( items, nil , 1111, -800 )

	-- local layer = GoodTableView.ItemTableView:create(items)
	-- local alertContent = {}
	-- alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1248") , g_sFontPangWa, 36,1, ccc3(0x00,0,0),type_stroke)
	-- alertContent[1]:setColor(ccc3(0xff, 0xc0, 0x00))
	-- local alert = BaseUI.createHorizontalNode(alertContent)
	-- layer:setContentTitle(alert)
	-- CCDirector:sharedDirector():getRunningScene():addChild(layer,1111)
end

local _ksTipTag = 101

function getTipSpriteByNum( num  )

	_tipSprite= CCSprite:create("images/common/tip_2.png")
	-- _tipSprite:setPosition(ccp(_rewardImgItem:getContentSize().width*0.97, _rewardImgItem:getContentSize().height*0.98))
	-- _tipSprite:setAnchorPoint(ccp(1,1))
	-- _rewardImgItem:addChild(_tipSprite,1)

	local numLabel = CCLabelTTF:create( tostring(num) , g_sFontName, 20)
	-- numLabel:setColor()
	numLabel:setPosition(ccp(_tipSprite:getContentSize().width/2,_tipSprite:getContentSize().height/2))
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	_tipSprite:addChild(numLabel,1,_ksTipTag)

	return _tipSprite
end

function refreshNum( sprite ,num )
	if( tonumber(num) <=0 ) then
		sprite:setVisible(false)
	else 	
		local numLabel= tolua.cast(sprite:getChildByTag(_ksTipTag), "CCLabelTTF") 
		numLabel:setString("" .. num)
	end
end



