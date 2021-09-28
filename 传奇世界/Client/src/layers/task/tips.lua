local Tips = class("Tips", function () return cc.Layer:create() end)
function Tips:ctor() --descfile, itemid
	-- body
      createSprite(self, "res/group/itemTips/6.png", cc.p(g_scrSize.width/2,g_scrSize.height/2))
	self.bg = createSprite(self, "res/group/itemTips/5.png", cc.p(g_scrSize.width/2, g_scrSize.height/2))
      --createScale9Sprite(self, "res/common/31.png", cc.p(g_scrSize.width/2,g_scrSize.height/2), cc.size(260, 100))
	--self.bg:setContentSize(cc.size(320, 320))
	--建立自己的触控机制
	local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	listener1:registerScriptHandler(function(touch, event)
        		return true
        		end,cc.Handler.EVENT_TOUCH_BEGAN )
   	local eventDispatcher = self:getEventDispatcher()
    	eventDispatcher:addEventListenerWithSceneGraphPriority(listener1,self)
    	--cc.Handler.EVENT_TOUCH_ENDED
    	listener1:registerScriptHandler(function( touch, event )
    	             -- body
                      local sizebg = self.bg:getContentSize()
                      local bg_touchpoint = self:convertToNodeSpace(touch:getLocation())
                      local touchinside = cc.rectContainsPoint(cc.rect(g_scrSize.width/2 - sizebg.width/2, g_scrSize.height/2 - sizebg.height/2, sizebg.width, sizebg.height), bg_touchpoint)
                      if touchinside then
                            cclog("touched tips内部!!!!!")
                      else
                            cclog("touched tips外部!!!!!")
                            removeFromParent(self)
                      end

    	end, cc.Handler.EVENT_TOUCH_ENDED)
      --self:showRingProps(1, 1)
end
function Tips:showRingProps(cid, lvl, ft)
-- body
      local ringid = (cid-1)*9 + lvl
      local sdata = require("src/layers/spiritring/ringdata").rdata
      local MRoleStruct = require("src/layers/role/RoleStruct")
      local rolejob = MRoleStruct:getAttr(ROLE_SCHOOL)

      local props = {}
      if rolejob == 1 then
            props = sdata[ringid].soldier_prop
      elseif rolejob == 2 then
            props = sdata[ringid].master_prop
      else
            props = sdata[ringid].taoist_prop
      end
      --self.bg:setContentSize(cc.size(270, 420))
      local sizebg = self.bg:getContentSize()
      createSprite(self.bg, "res/layers/spiritring/ringkuang.png", cc.p(190, sizebg.height - 48))
      local name = "res/layers/spiritring/name"..cid..".png"
      createSprite(self.bg, name, cc.p(175, sizebg.height - 48))
      local lv =createLabel(self.bg, "LV"..lvl, cc.p(175, sizebg.height - 48),cc.p(0, 0.5),20) --sdata[ringid].name..
      --lv:setColor(cc.c3b(0, 255, 0))
      local fight = ft or 1000
      local labe1 = createLabel(self.bg, game.getStrByKey("combat_power") .. " +"..fight, cc.p(190, sizebg.height - 105),cc.p(0.5, 0.5),22)
      labe1:setColor(cc.c3b(222,165,75))

      createSprite(self.bg, "res/common/bg/titleBg-3.png", cc.p(190, sizebg.height - 140))
      createSprite(self.bg, "res/common/bg/titleBg-3.png", cc.p(190, sizebg.height - 270))
      createLabel(self.bg,game.getStrByKey("ring_property"),cc.p(190, sizebg.height - 140),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
      createLabel(self.bg,game.getStrByKey("ring_result"),cc.p(190, sizebg.height - 270),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
      -- createSprite(self.bg, "res/layers/spiritring/propadd.png", cc.p(235, sizebg.height - 140))
      -- createSprite(self.bg, "res/layers/spiritring/effect.png", cc.p(255, sizebg.height - 270))
      local labelxg = createLabel(self.bg, game.getStrByKey("ringrange"), cc.p(175, 20),cc.p(0.5, 0.5),18,true,nil,nil,MColor.lable_yellow)
      local ring_eff_text = createMultiLineLabel(self.bg, sdata[ringid].text, cc.p(190, sizebg.height - 330),cc.p(0.5, 0.5),18, nil, nil, nil, nil, 250, 24)--sdata[ringid].text

      local num = #props
      for i = 1, num do
            --local m = (i - 1)%2
            --local n = math.floor( (i - 1)/2)
            local target1 = require("src/layers/task/tasktargetlabel").new(16)
            --target1:setPosition( 10 + 122*m, sizebg.height - 170 - 22*n )
            target1:setPosition( 132, sizebg.height - 148 - 22*i )
            self.bg:addChild(target1)
            --target1:setText1("攻击力", cc.c3b(221, 136, 71), "+1000", cc.c3b(255, 255, 255))
            if props[i][1]  == "2" then
                  target1:setText1(game.getStrByKey("life_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
            elseif props[i][1]  == "3" then
                  target1:setText1(game.getStrByKey("magic_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
            elseif props[i][1]  == "5" then
                  target1:setText1(game.getStrByKey("physical_attack"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3],cc.c3b(0, 255, 0) )
            elseif props[i][1]  == "7" then
                  target1:setText1(game.getStrByKey("magic_attack"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0) )
            elseif props[i][1]  == "9" then
                  target1:setText1(game.getStrByKey("taoism_attack"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0))
            elseif props[i][1]  == "11" then
                  target1:setText1(game.getStrByKey("physical_defense"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0) )
            elseif props[i][1]  == "13" then
                  target1:setText1(game.getStrByKey("magic_defense"), cc.c3b(215,194,131), props[i][2].."-"..props[i][3], cc.c3b(0, 255, 0) )
            elseif props[i][1]  == "16" then
                  target1:setText1(game.getStrByKey("hit_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
            elseif props[i][1]  == "17" then
                  target1:setText1(game.getStrByKey("blink_num"), cc.c3b(215,194,131), props[i][2], cc.c3b(0, 255, 0))
            end
      end
end

return Tips