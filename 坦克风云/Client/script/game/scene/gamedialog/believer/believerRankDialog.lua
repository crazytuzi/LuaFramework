local believerRankDialog=commonDialog:new()

function believerRankDialog:new(parent)
	local nc={
		parent=parent,
	}
	setmetatable(nc,self)
	self.__index=self
    nc.parent = parent
	nc.layerNum=layerNum
    nc.tab1 = nil
    nc.tabLayer1 = nil
    nc.tab2 = nil
    nc.tabLayer2 = nil
	return nc
end
function believerRankDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end
    self:tabClick(0)
end

function believerRankDialog:tabClick(idx)

    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then

        if self.tabLayer2==nil then
        	local function battleRankCall()
        		local believerBattleRankTab = G_requireLua("game/scene/gamedialog/believer/believerBattleRankTab")
	            self.tab2=believerBattleRankTab:new()
	            self.tabLayer2=self.tab2:init(self.layerNum)
                self.tabLayer2:setPosition(ccp(0,0))
	            self.bgLayer:addChild(self.tabLayer2)
	        end
	        believerVoApi:socketRankInfo(2,battleRankCall)
        	
        else
            self.tabLayer2:setVisible(true)
            self.tabLayer2:setPosition(ccp(0,0))
        end
        
        
        if self.tabLayer1 ~= nil then
            self.tabLayer1:setVisible(false)
            self.tabLayer1:setPosition(ccp(10000,0))
        end            
    elseif idx==0 then
            
        if self.tabLayer2~=nil then
            self.tabLayer2:setPosition(ccp(999333,0))
            self.tabLayer2:setVisible(false)
        end
        
        if self.tabLayer1==nil then
        	local believerSegRankTab = G_requireLua("game/scene/gamedialog/believer/believerSegRankTab")
            self.tab1=believerSegRankTab:new()
            self.tabLayer1=self.tab1:init(self.layerNum)
            self.bgLayer:addChild(self.tabLayer1)
        else
             self.tabLayer1:setVisible(true)
        end

        self.tabLayer1:setPosition(ccp(0,0))
    end
end

function believerRankDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    -- self.panelTopLine:setPositionY(G_VisibleSizeHeight-182)

    local function touchTip()
        local believerCfg=believerVoApi:getBelieverCfg()
        local args={
            arg2={believerCfg.rankLimit1[1],believerCfg.rankLimit1[2]},
        }
        local strTb={}
        for i=1,3 do
            local str=getlocal("believer_rankTip"..i,args["arg"..i])
            table.insert(strTb,str)
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),strTb)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-195),{},nil,nil,28,touchTip,true,1)
end
function believerRankDialog:initTableView()
	
end

-- function believerRankDialog:tick()
-- 	  if self and self.bgLayer and self.tab1 and self.tabLayer1 then 

-- 	    	self.tab1:tick()

-- 	  end

-- 	  if self and self.bgLayer and self.tab2 and self.tabLayer2 then 

-- 	    	self.tab2:tick()

-- 	  end
-- end

function believerRankDialog:dispose()
	if self.tab1~=nil then
        self.tab1:dispose()
    end
    if self.tab2~=nil then
        self.tab2:dispose()
    end
    self.tab1 = nil
    self.tabLayer1 = nil
    self.tab2 = nil
    self.tabLayer2 = nil
    self.layerNum = nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
end

return believerRankDialog