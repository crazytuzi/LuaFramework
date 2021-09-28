-- 累计消费
local temp113 = class( "temp113" , function() return cc.Node:create() end )
function temp113:ctor( params )
    self.data = {}

    local base_node = createSprite( self , "res/layers/activity/bg7.jpg" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )

    self.viewLayer = cc.Node:create()
    self:addChild( self.viewLayer )

    ---------------------------------------------------------------------------------------------------------------------
    local function createLayout()
        if self.viewLayer then self.viewLayer:removeAllChildren() end

        self.data = DATA_Activity.CData["netData"]


        local centerBgSpr = createSprite( self.viewLayer , "res/common/table/cell17.png" , cc.p( 350 , 115 ) , cc.p( 0.5 , 0 ) )

        local groupAwards = __createAwardGroup( self.data.awards , false , 100 , nil , false ) 
        setNodeAttr( groupAwards , getCenterPos(centerBgSpr, 15) , cc.p( 0.5 , 0.5 ) )
        centerBgSpr:addChild( groupAwards )

        local totalCostStr = "";
        if self.data.progress > self.data.money then
            totalCostStr = game.getStrByKey("total_cost") .. ": " .. self.data.money .. "/" .. self.data.money;
        else
            totalCostStr = game.getStrByKey("total_cost") .. ": " .. self.data.progress .. "/" .. self.data.money;
        end
        createLabel( self.viewLayer , totalCostStr, cc.p( 350 , 82 ) , cc.p( 0.5 , 0 ) , 22 , true , 200 , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )

        --达成状态(0:可领取 1:未达成 2:已领取)
        local function getFun()
            if self.data.state == 0 then
                DATA_Activity:getAward( { awards = self.data.awards } )
            end
        end
        
        local getRewardBtn = createTouchItem( self.viewLayer , "res/component/button/2.png", cc.p( 350 , 44 ) , function()  getFun() end , true  ) 
        getRewardBtn:setEnable( self.data.state == 0 )
        local strCfg = { game.getStrByKey( "get_awards" )  , game.getStrByKey("no_to") , game.getStrByKey( "getOver" ) }
        createLabel( getRewardBtn , strCfg[self.data.state+1] , getCenterPos( getRewardBtn ) , cc.p( 0.5 , 0.5 ) , 23 , true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
        
    end


    DATA_Activity:readData( createLayout )

end

return temp113