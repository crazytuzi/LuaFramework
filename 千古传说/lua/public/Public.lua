--[[
    公共方法

    --By: haidong.gan
    --2013/11/11
]]
local Public = {}

function showLongLoading(isReconect)
    isReconect = isReconect or false;
    local currentScene = Public:currentScene()
    if not isReconect then
        if currentScene ~= nil and currentScene.getTopLayer and currentScene:getTopLayer().__cname == "ReconnectLayer" then
            return;
        end
    end

    LoadingLayer:show(2);
end

function showLoading(isReconect)
    isReconect = isReconect or false;
    local currentScene = Public:currentScene()
    if not isReconect then
        if currentScene ~= nil and currentScene.getTopLayer and currentScene:getTopLayer().__cname == "ReconnectLayer" then
            return;
        end
    end
    LoadingLayer:show();
end

function hideLoading()
    LoadingLayer:hide()
end

function hideAllLoading()
    LoadingLayer:clearForCuurentScene()
end

function createUIByLuaNew(uiPath)
   if BaseLayer.isDebug then
        TFDirector:unRequire(uiPath);
   end
   return createUIByLua(uiPath, nil, GameConfig.FONT_TYPE);
end

function requireNew(uiPath)
   if BaseLayer.isDebug then
        TFDirector:unRequire(uiPath);
   end
   return require(uiPath);
end

function Public:currentScene()
  local currentScene = nil;
  if me.Director.getNextScene then
      currentScene = me.Director:getNextScene();
  end
  if not currentScene then
      currentScene = me.Director:getRunningScene();
  end
  return currentScene;
end

function Public:createIconNumNode(rewardItem)
    local node  = createUIByLuaNew("lua.uiconfig_mango_new.common.IconNumItem");
    self:loadIconNode(node,rewardItem)
    return node;
end
function Public:createIconNumAndBagNode(rewardItem)
    local node  = createUIByLuaNew("lua.uiconfig_mango_new.common.IconNumItem");
    if rewardItem.type == EnumDropType.GOODS then
      self:loadIconBagNode(node,rewardItem)
    else
      self:loadIconNode(node,rewardItem,true)
    end
    return node;
end

function Public:createRewardNode(rewardItem)
    local node  = createUIByLuaNew("lua.uiconfig_mango_new.common.IconRewardItem");
    self:loadIconNode(node,rewardItem)
    return node;
end

function Public:isPiece(rewardItem)
    local isPiece = false;

    -- 蛇胆不添加碎片标示
    if rewardItem.itemid and rewardItem.itemid >= 3000 and rewardItem.itemid <= 3003 then
      return false,0
    end

    if rewardItem.type == EnumDropType.GOODS and rewardItem.itemid then

        local item = ItemData:objectByID(rewardItem.itemid)
        if item.type == EnumGameItemType.Soul then
            return true,EnumGameItemType.Soul ;
        elseif item.type == EnumGameItemType.Piece then
            return true,EnumGameItemType.Piece ;
        elseif item.type == EnumGameItemType.SkyBookPiece then
            return true,EnumGameItemType.SkyBookPiece ;
        elseif item.type == EnumGameItemType.SBStonePiece then
            return true,EnumGameItemType.SBStonePiece ;
        elseif item.type == EnumGameItemType.HeadPicFrame then
            return true,EnumGameItemType.HeadPicFrame ;
        end
    end
    return false,0;
end

function Public:addStarImg(img_icon,star,positionY)
    positionY = positionY or img_icon:getSize().height/2 - 8;
    for i=1,star do
        local imgStar = img_icon:getChildByTag(10090 + i);
        if not imgStar then 
            imgStar = TFImage:create("ui_new/equipment/tjp_xingxing_icon.png");
            imgStar:setTag(10090 + i);
            imgStar:setPosition(ccp(- img_icon:getSize().width/2 + 23 + 17 *(i-1) ,positionY));

            img_icon:addChild(imgStar);
        end
    end
    for i=star + 1,5 do
        local imgStar = img_icon:getChildByTag(10090 + i);
        if imgStar then
          img_icon:removeChildByTag(10090 + i,true);
        end
    end
end

function Public:addPieceImg(img_icon,rewardItem,isPiece,scale)
    if img_icon == nil then
      return
    end
    if scale == nil then
        scale = 0.9
    end
    local imgPiece = img_icon:getChildByTag(10087);
    if isPiece == nil then
      isPiece = self:isPiece(rewardItem);
    end
    if isPiece then
      local item      = ItemData:objectByID(rewardItem.itemid)
      local quality   = item.quality
      local pieceRes  = "ui_new/common/icon_bg/s"..quality..".png"
      
      if not imgPiece then


        imgPiece = TFImage:create(pieceRes);

        -- imgPiece = TFImage:create("ui_new/common/icon_bg/pz_bg_zhezao_124.png");
        imgPiece:setTag(10087);
        imgPiece:setScale(scale)
        img_icon:addChild(imgPiece);
        -- imgPiece:setScale(img_icon:getSize().width/118)
      else
        imgPiece:setTexture(pieceRes)
      end
    else
        if imgPiece then 
          imgPiece:removeFromParent();
        end
    end
end

function Public:addFrameImg(img_icon,frameId,isAdd)
	local imgFrame = img_icon:getChildByTag(11011);
	if isAdd == false then
		if imgFrame then
			imgFrame:removeFromParent();
		end
	else
    if frameId == nil then
        if imgFrame then
            imgFrame:removeFromParent();
        end
        return;
    end
		local frameRes  = "ui_new/team/img_frame"..frameId..".png";
		if TFFileUtil:existFile(frameRes) == false then
			if imgFrame then
				imgFrame:removeFromParent();
			end
			return;
		end
		if not imgFrame then
			imgFrame = TFImage:create(frameRes);
			imgFrame:setTag(11011);
			img_icon:addChild(imgFrame);
		else
			imgFrame:setTexture(frameRes);
		end
	end
end

function Public:addInfoListen(btn_frame,enabled,showType,playerId,serverId)
    if nil == btn_frame then
        return
    elseif nil == playerId or nil == showType then
        btn_frame:setTouchEnabled(false)
        return
    end
    playerId = tonumber(playerId)
    btn_frame:setTouchEnabled(enabled)
    if enabled == false then
        return
    end
    if playerId == MainPlayer:getPlayerId() then
        btn_frame:setTouchEnabled(false)
        return
    end
    local callFunc = function (sender)
        if playerId <= 0 then
          return
        end
        OtherPlayerManager:requestPlayerInfo(showType,playerId,serverId)
    end
    btn_frame:addMEListener(TFWIDGET_CLICK, audioClickfun(callFunc))
end

function Public:addLianTiEffect(node,quality,isAdd,scale,index)
  local effect = node.effect
  scale = scale or 1
  if isAdd == false then
    if effect then
      effect:removeFromParent();
      node.effect = nil
    end
  else
    if quality == nil or quality <= 0 then
        if effect then
            effect:removeFromParent();
            node.effect = nil
        end
        return
    end
    if effect == nil then
      print("addLianTiEffect")
      TFResourceHelper:instance():addArmatureFromJsonFile("effect/lianti2_"..quality..".xml")
      local effect = TFArmature:create("lianti2_"..quality.."_anim")
      effect:setScale(scale)
      -- effect:setAnimationFps(GameConfig.ANIM_FPS)
      local size = node:getContentSize()
      effect:setPosition(size.width*0.5,size.height*0.5)
      node:addChild(effect , 100)
      node.effect = effect
      node.effect.quality = quality
    else
      if node.effect.quality ~= quality then
        effect:removeFromParent();
        node.effect = nil
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/lianti2_"..quality..".xml")
        local effect = TFArmature:create("lianti2_"..quality.."_anim")
        effect:setScale(scale)
        -- effect:setAnimationFps(GameConfig.ANIM_FPS)
        local size = node:getContentSize()
        effect:setPosition(size.width*0.5,size.height*0.5)
        node:addChild(effect , 100)
        node.effect = effect
        node.effect.quality = quality
      end
    end
    if index == nil then
        index = 0
    end
    node.effect:playByIndex(index, -1, -1, 1)
  end
end

function Public:loadIconNode(node,rewardItem,isShowOne)
    if isShowOne == nil then
      isShowOne = false
    end
   if node and rewardItem then
        local img_icon  = TFDirector:getChildByPath(node, 'img_icon');
        local txt_num   = TFDirector:getChildByPath(node, 'txt_num');
        local txt_name  = TFDirector:getChildByPath(node, 'txt_name');
        local bg_icon   = TFDirector:getChildByPath(node, 'bg_icon');

        if bg_icon then
            bg_icon:setTextureNormal(GetColorIconByQuality_118(rewardItem.quality));
            function onClick( sender )
              Public:ShowItemTipLayer(rewardItem.itemid, rewardItem.type);
            end
            bg_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(onClick));
        end
        if txt_name then
            txt_name:setText(rewardItem.name);
        end
        if img_icon then
            img_icon:setTexture(rewardItem.path);
            img_icon:setScale(0.8)
            self:addPieceImg(img_icon,rewardItem);
        end
        if txt_num then
            -- txt_num:setText("X" .. rewardItem.number);
            txt_num:setText(rewardItem.number);
            if rewardItem.number < 2 and isShowOne == false then
                txt_num:setVisible(false);
            else
                txt_num:setVisible(true);
            end
        end

        return node;
    end
end
function Public:loadIconBagNode(node,rewardItem)
   if node and rewardItem then
        if rewardItem.type ~= EnumDropType.GOODS then
            return Public:loadIconNode(node,rewardItem)
        end
        local img_icon  = TFDirector:getChildByPath(node, 'img_icon');
        local txt_num   = TFDirector:getChildByPath(node, 'txt_num');
        local txt_name  = TFDirector:getChildByPath(node, 'txt_name');
        local bg_icon   = TFDirector:getChildByPath(node, 'bg_icon');

        if bg_icon then
            bg_icon:setTextureNormal(GetColorIconByQuality_118(rewardItem.quality));
            function onClick( sender )
              Public:ShowItemTipLayer(rewardItem.itemid, rewardItem.type);
            end
            bg_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(onClick));
        end
        if txt_name then
            txt_name:setText(rewardItem.name);
        end
        if img_icon then
            img_icon:setTexture(rewardItem.path);
            self:addPieceImg(img_icon,rewardItem);
        end
        if txt_num then
            local num_bag = BagManager:getItemNumById(rewardItem.itemid)
            txt_num:setText(num_bag.."/"..rewardItem.number);
            -- if rewardItem.number < 2 then
            --     txt_num:setVisible(false);
            -- else
            --     txt_num:setVisible(true);
            -- end
        end

        return node;
    end
end

function Public:createIconNameNumNode(rewardItem)
    local node  = createUIByLuaNew("lua.uiconfig_mango_new.common.IconNameItem");
    self:loadIconNode(node,rewardItem)
    return node;
end

function Public:indexAtArr(arr,item)
    for index,arrItem in ipairs(arr) do
        if arrItem == item then
           return index;
        end
    end
    return -1;
end


function Public:bindScrollFun(scrollView)

    function scrollView:bindScrollArrow(ui)
        local img_arrow_left        = TFDirector:getChildByPath(ui, 'img_arrow_left');
        local img_arrow_right       = TFDirector:getChildByPath(ui, 'img_arrow_right');
        local img_arrow_top         = TFDirector:getChildByPath(ui, 'img_arrow_top');
        local img_arrow_bottom      = TFDirector:getChildByPath(ui, 'img_arrow_bottom');

        if img_arrow_left then
            img_arrow_left:setVisible(false);
        end
        if img_arrow_right then
            img_arrow_right:setVisible(false);
        end
        if img_arrow_top then
            img_arrow_top:setVisible(false);
        end
        if img_arrow_bottom then
            img_arrow_bottom:setVisible(false);
        end
        
        local onUpdated = function(event)
            if img_arrow_left and img_arrow_right then
                local scrollViewWidth = (self.getTableViewSize and self:getTableViewSize().width) or self:getContentSize().width;
                local innerContainerWidth = (self.getInnerContainerSize and self:getInnerContainerSize().width) or self:getContentSize().width;
                local contentOffset = self:getContentOffset();

                if contentOffset.x > - 100 then
                    img_arrow_right:setVisible(false);
                else
                    img_arrow_right:setVisible(true);
                end

                if contentOffset.x < scrollViewWidth - innerContainerWidth + 100 then
                    img_arrow_left:setVisible(false);
                else
                    img_arrow_left:setVisible(true);
                end
            end

           if img_arrow_top and img_arrow_bottom then
                local scrollViewHeight =(self.getTableViewSize and self:getTableViewSize().height) or self:getContentSize().height;
                local innerContainerHeight = (self.getInnerContainerSize and self:getInnerContainerSize().height) or self:getContentSize().height;
           
                local contentOffset = self:getContentOffset();

                if contentOffset.y > - 100 then
                    img_arrow_top:setVisible(false);
                else
                    img_arrow_top:setVisible(true);
                end

                if contentOffset.y < scrollViewHeight - innerContainerHeight + 100 then
                    img_arrow_bottom:setVisible(false);
                else
                    img_arrow_bottom:setVisible(true);
                end
            end
        end;
        self.arrowIimer = TFDirector:addTimer(0.3, -1, nil, onUpdated); 
    end


    function scrollView:cancelScrollArrow()
        TFDirector:removeTimer(self.arrowIimer);
        self.onUpdated = nil;
    end


    --使某个位置，按X居中
    function scrollView:setInnerContainerSizeForHeight(height)
      local innerContainerSizeForHeight = height
      self:setInnerContainerSize(CCSizeMake(self:getInnerContainerSize().width,innerContainerSizeForHeight));

      local offsetY = self:getSize().height - height;
      if offsetY > 0 then
          local childrenArr = self:getChildren();
          for i=0,childrenArr:count()-1 do
              local child = childrenArr:objectAtIndex(i);
              child:setPosition(ccp(child:getPosition().x, child:getPosition().y + offsetY));
          end
      end
    end 

    --使某个位置，按X居中
    function scrollView:scrollToCenterForPositionX(forPositionX, dt)
       dt = dt or 0;
       local scrollViewWidth = (self.getTableViewSize and self:getTableViewSize().width) or self:getContentSize().width;
       local innerContainerWidth = (self.getInnerContainerSize and self:getInnerContainerSize().width) or self:getContentSize().width;

        --置左
       if(innerContainerWidth < scrollViewWidth) then
          self:setContentOffset(ccp(0, 0),dt);

        --底部1/2以下
       elseif forPositionX < scrollViewWidth/2 then
          self:setContentOffset(ccp(0, 0),dt);
       else
          local pt = math.max(scrollViewWidth/2 - forPositionX , scrollViewWidth - innerContainerWidth);
          self:setContentOffset(ccp(pt,0), dt);
       end 
    end 

    --使某个位置，按Y居中
    function scrollView:scrollToCenterForPositionY(forPositionY, dt)
       dt = dt or 0;
       local scrollViewHeight =(self.getTableViewSize and self:getTableViewSize().height) or self:getContentSize().height;
       local innerContainerHeight = (self.getInnerContainerSize and self:getInnerContainerSize().height) or self:getContentSize().height;
       
        --置顶
       if(innerContainerHeight < scrollViewHeight) then
          self:setContentOffset(ccp(0, scrollViewHeight - innerContainerHeight), dt);
        --底部1/2以下
       elseif forPositionY < scrollViewHeight/2 then
          self:setContentOffset(ccp(0, 0), dt);
       else
          local pt = math.max(scrollViewHeight/2 - forPositionY,scrollViewHeight - innerContainerHeight);
          self:setContentOffset(ccp(0, pt), dt);
       end 
    end 

    --纵向，滚动到最后一条
    function scrollView:scrollToYLast(dt)
       dt = dt or 0;  
       local scrollViewHeight = (self.getTableViewSize and self:getTableViewSize().height) or self:getContentSize().height;
       local innerContainerHeight = (self.getInnerContainerSize and self:getInnerContainerSize().height) or self:getContentSize().height;
       
       if(innerContainerHeight < scrollViewHeight) then
          self:setContentOffset(ccp(0, scrollViewHeight-innerContainerHeight), dt);
       else
          self:setContentOffset(ccp(0, 0), dt);
       end 
    end

    --纵向，滚动到第一条
    function scrollView:scrollToYTop(dt)
       dt = dt or 0;
       local scrollViewHeight = (self.getTableViewSize and self:getTableViewSize().height) or  self:getContentSize().height;
       local innerContainerHeight = (self.getInnerContainerSize and self:getInnerContainerSize().height) or self:getContentSize().height;
       
       self:setContentOffset(ccp(0, scrollViewHeight-innerContainerHeight), dt);
    end 

    --横向，滚动到最后一条
    function scrollView:scrollToXLast(dt)
       dt = dt or 0;
       local scrollViewWidth = (self.getTableViewSize and self:getTableViewSize().width) or self:getContentSize().width;
       local innerContainerWidth = (self.getInnerContainerSize and self:getInnerContainerSize().width) or self:getContentSize().width;

       if innerContainerWidth < scrollViewWidth then
           self:setContentOffset(ccp(0, 0), dt);   
       else
           self:setContentOffset(ccp(scrollViewWidth-innerContainerWidth, 0), dt);
       end 
    end 

    --横向，滚动到第一条
    function scrollView:scrollToXTop(dt)
       dt = dt or 0;
       local scrollViewWidth = (self.getTableViewSize and self:getTableViewSize().width) or self:getContentSize().width;
       local innerContainerWidth = (self.getInnerContainerSize and self:getInnerContainerSize().width) or self:getContentSize().width;

       self:setContentOffset(ccp(0, 0), dt);
    end


    --纵向，滚动的百分比
    function scrollView:getScrollYPercent()
        local contentOffset = self:getContentOffset();
        local innerContainerHeight = (self.getInnerContainerSize and self:getInnerContainerSize().height) or self:getContentSize().height;
        local percent = contentOffset.y/innerContainerHeight*(-1)
        percent = percent <= 1 and percent or 1
        return math.floor(percent*100)
    end
    --横向，滚动的百分比
    function scrollView:getScrollXPercent()
        local contentOffset = self:getContentOffset();
        local innerContainerWidth = (self.getInnerContainerSize and self:getInnerContainerSize().width) or self:getContentSize().width;
        local percent = contentOffset.x/innerContainerWidth*(-1)
        percent = percent <= 1 and percent or 1
        return math.floor(percent*100)
    end
end

--打开物品或卡牌描述界面 itemID：物品或卡牌模板id，type：1物品 2卡牌
function Public:ShowItemTipLayer(itemID, type, num,level)
  local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.item.ItemTipLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
  layer.toScene = TFDirector:currentScene()
  layer:loadData({itemID, type, num});
  AlertManager:show()
  if level then
      layer:setTipText("LV" .. level)
  end
end


function Public:addBtnWaterEffect(node, bAdd, index)
    if bAdd then
        if node.effect == nil then
            ModelManager:addResourceFromFile(2, "btn_common_small", 1)
            local effect = ModelManager:createResource(2, "btn_common_small")
            node:addChild(effect , 100)
            node.effect = effect
        end
        ModelManager:playWithNameAndIndex(node.effect, "", 0, 1, -1, -1)

        return node.effect
    else
        if node.effect then
            node.effect:removeFromParent()
            node.effect = nil
        end
    end
end

--added by wuqi
function Public:addVipEffect(btn, vipLevel, scale)
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end

    if not scale then
        scale = 1
    end

    vipLevel = tonumber(vipLevel)
    if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
        return
    end
    local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    effect:setScale(scale)
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end

function Public:addEffectWidthPosY(eftID, parentWidget, posY)
    ModelManager:addResourceFromFile(2, eftID, 1)
    local eft = ModelManager:createResource(2, eftID)
    parentWidget:addChild(eft)
    eft:setPositionY(posY)
    ModelManager:playWithNameAndIndex(eft, "", 0, 1, -1, -1)
end

function Public:addModel(modelID, parentWidget, posX, posY, actionName, scale)
    ModelManager:addResourceFromFile(1, modelID, 1)
    local model = ModelManager:createResource(1, modelID)
    parentWidget:addChild(model)
    model:setPosition(ccp(posX, posY))
    model:setScale(scale)
    ModelManager:playWithNameAndIndex(model, actionName, -1, 1, -1, -1)
    return model
end

function Public:addEffect(eftID, parentWidget, posX, posY, scale, times)
    times = times == nil and 1 or times
    ModelManager:addResourceFromFile(2, eftID, 1)
    local effect = ModelManager:createResource(2, eftID)
    parentWidget:addChild(effect)
    parentWidget.effect = effect
    effect:setPosition(ccp(posX, posY))
    effect:setScale(scale)
    ModelManager:playWithNameAndIndex(effect, "", 0, times, -1, -1)
    return effect
end

return Public;