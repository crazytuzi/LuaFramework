local FactionCreateLayer = class("FactionCreateLayer",function() return cc.Layer:create() end )

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionCreateLayer:ctor(parentBg)
	self.getString = game.getStrByKey

  local baseNode = cc.Node:create()
  self:addChild(baseNode)
  baseNode:setPosition(cc.p(0, 0))
  self.baseNode = baseNode

  --createSprite(baseNode,"res/common/bg/bg-6.png",cc.p(parentBg:getContentSize().width/2,25),cc.p(0.5,0))
 
  createSprite(baseNode, path.."7.png", cc.p(parentBg:getContentSize().width/2,42), cc.p(0.5, 0))

  local infoBg = createSprite(baseNode,pathCommon.."bg/infoBg11.png",cc.p(parentBg:getContentSize().width-37,47),cc.p(1,0))
  createSprite(infoBg,pathCommon.."bg/infoBg11-3.png",cc.p(infoBg:getContentSize().width/2,105),cc.p(0.5,0.5))

	local edit_box = createEditBox(infoBg,pathCommon.."bg/inputBg.png",cc.p(infoBg:getContentSize().width/2,435),cc.size(252,48),MColor.lable_black)
  edit_box:setPlaceHolder(game.getStrByKey("faction_name_input"))
  edit_box:setPlaceholderFontSize(20)
  edit_box:setPlaceholderFontColor(MColor.gray)
  createLabel(infoBg,game.getStrByKey("faction_name_input_tip"),cc.p(infoBg:getContentSize().width/2,380), cc.p(0.5, 0), 20, true,nil,nil,MColor.red)

  local titleBg = createSprite(infoBg,"res/faction/title_min4.png",cc.p(infoBg:getContentSize().width/2,325),cc.p(0.5,0))
  createLabel(titleBg,game.getStrByKey("faction_title_cost"),getCenterPos(titleBg), cc.p(0.5, 0.5), 22, true,nil,nil,MColor.lable_yellow)

	local createFunc = function()
		local str = edit_box:getText()

    if self:checkNameRule(str) == false then
      return
    end

    if DirtyWords:isHaveDirytWords(str) then
        TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") })
        return
    end
--[[
    local shieldList =  getConfigItemByKey("shieldword","name")
    if shieldList then
      for k,v in pairs(shieldList) do
        local pos = string.find(str,k) 
        if pos then 
          TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") })
          return
        end
      end
    end
]]
		if string.len(str) > 0 then
      if str == "*#8888*#" and self.create_mode == 1 then
        require("src/layers/setting/MsgPushLayer").new()
      end
      if string.find(str, " ") ~= nil then
        MessageBox(self.getString("faction_nospace_tip"), nil, nil)
      else
			  local t = {}
        t.facName = str;
        t.cType = self.create_mode;
        dump(t)
        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_CREATEFACTION, "CreateFaction", t)
      end
		else 
			MessageBox(self.getString("faction_noname_tip"), nil, nil)
		end
	end
	local comfirm_menu = createMenuItem(infoBg,"res/component/button/50.png",cc.p(infoBg:getContentSize().width/2,55),createFunc)
	local sure_or_cancel = createLabel(comfirm_menu, self.getString("faction_tab_create"),cc.p(comfirm_menu:getContentSize().width/2,comfirm_menu:getContentSize().height/2),nil, 22,true)


  local hight_items = {}
  self.create_mode = 1
  for i=1,2 do
  	local func = function() 
  		self.create_mode = i
  		for k,v in pairs(hight_items)do
  			v:setVisible(i==k)
  		end
  	end
  	local item = createScale9SpriteMenu(infoBg,"res/faction/8.png",cc.size(270, 60),cc.p(infoBg:getContentSize().width/2,280-(i-1)*110),func)
    item:setActionEnable(false)
    local pos = getCenterPos(item)
    if i == 1 then       
 		createLabel(item,game.getStrByKey("faction_create_cost_1"),cc.p(pos.x - 90, pos.y),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)    
        createLabel(item,game.getStrByKey("faction_create_tips"),cc.p(pos.x - 90, pos.y - 30),cc.p(0,0.5),16,nil,nil,nil,MColor.lable_black)
        createLabel(item,game.getStrByKey("faction_create_tips2"),cc.p(pos.x - 74, pos.y - 50),cc.p(0,0.5),16,nil,nil,nil,MColor.lable_black)        
        createSprite(item,"res/component/checkbox/2.png",cc.p(pos.x - 92, pos.y),cc.p(1,0.5))
        hight_items[i] = createSprite(item,"res/component/checkbox/2-1.png",cc.p(pos.x - 92, pos.y),cc.p(1,0.5))
    
    else
        createLabel(item,game.getStrByKey("faction_create_cost_2"),cc.p(pos.x - 90, pos.y),cc.p(0,0.5),20,nil,nil,nil,MColor.lable_yellow)
        createSprite(item,"res/component/checkbox/2.png",cc.p(pos.x - 92, pos.y),cc.p(1,0.5))
        hight_items[i] = createSprite(item,"res/component/checkbox/2-1.png",cc.p(pos.x - 92, pos.y),cc.p(1,0.5))
        hight_items[i]:setVisible(false)
    end
  end
end

function FactionCreateLayer:checkNameRule(name)
  -- log(name)
  -- dump(string.utf8len(name))
  -- dump(string.utf8sub(name, 0, 1))
  -- dump(string.utf8sub(name, -1))
  
  -- if string.utf8len(txt) > 6 then
  --  TIPS({ type = 1 , str = game.getStrByKey("invilid_namelen") , isMustShow = true})
  --  return
  -- elseif string.utf8len(txt) <= 0 then
  --  TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
  --  return
  -- end

  if string.find(name, " ") or string.find(name, "%^") then
    TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
    return false
  end

  if string.utf8sub(name, 0, 1) == " " then
    TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_1") , isMustShow = true})
    return false
  elseif string.utf8sub(name, -1) == " " then
    TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_1") , isMustShow = true})
    return false
  end

  local word = {"传奇世界", "传世", "GM", "gm", "官方", "活动", "宣传", "推广"}
  for i,v in ipairs(word) do
    if string.find(name, v) then
      --TIPS({ type = 1 , str = string.format(game.getStrByKey("role_name_rule_2"), v) , isMustShow = true})
      TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
      return false
    end
  end

  if string.find(name, "\n") or string.find(name, "\r") then
    TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_3") , isMustShow = true})
    return false
  end

  log("11111111111111111111111111111")
  return true
end

return FactionCreateLayer