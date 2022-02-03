-- --------------------------------------------------------------------
-- 市场
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-04
-- --------------------------------------------------------------------
MarketController = MarketController or BaseClass(BaseController)

MarketTabConst = {
	gold_market = 1, --金币市场
	sliver_market = 2, --银币市场
	gold_sell = 3, --金币出售
	sliver_sell = 4, --银币摆摊
}

MaketSubTabConst = {
    All = 0,--金币全部/银币古董
	Skill = 1 ,--技能
	Form = 2, --阵法
	Break = 3, --突破
	Other = 4, --其他
}

function MarketController:config()
    self.model = MarketModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.price_list = {}
end

function MarketController:getModel()
    return self.model
end

function MarketController:registerEvents()
end

function MarketController:registerProtocals()
    self:RegisterProtocal(23500, "handle23500")     --获取金币市场指定分类的数据 
    self:RegisterProtocal(23501, "handle23501")     --购买金币市场物品
    self:RegisterProtocal(23502, "handle23502")     --出售金币市场物品
    self:RegisterProtocal(23518, "handle23518")     --更新金币市场分类的数据
    self:RegisterProtocal(23520, "handle23520")     --金币市场获取玩家限购数据

    self:RegisterProtocal(23504, "handle23504")     --银币市场物品上架
    self:RegisterProtocal(23505, "handle23505")     --购买银币市场物品
    self:RegisterProtocal(23506, "handle23506")     --银币市场物品下架
    self:RegisterProtocal(23507, "handle23507")     --获取银币市场摊位信息
    self:RegisterProtocal(23508, "handle23508")     --查询银币市场物品价格
    self:RegisterProtocal(23509, "handle23509")     --银币市场刷新/获取数据
    self:RegisterProtocal(23511, "handle23511")     --银币市场提取摊位收益
    self:RegisterProtocal(23512, "handle23512")     --银币市场开放摊位
    self:RegisterProtocal(23513, "handle23513")     --银币市场重新上架
    self:RegisterProtocal(23514, "handle23514")     --银币市场一键操作

    self:RegisterProtocal(23516, "handle23516")     --查询市场、商城物品价格
end

--获取金币市场指定分类的数据 
function MarketController:sender23500( catalg  )
    local protocal ={}
    protocal.catalg = catalg
    self:SendProtocal(23500,protocal)
end

function MarketController:handle23500( data )
    --Debug.info(data)
    self.model:setGoldShopList(data)
    self.dispather:Fire(MarketEvent.Update_Gold_Category,data)
end

--购买金币市场物品
function MarketController:sender23501( base_id,num )
    local protocal ={}
    protocal.base_id = base_id
    protocal.num = num
    self:SendProtocal(23501,protocal)
end

function MarketController:handle23501( data )
    if data.flag == 1 then
        if self.market_win and self.market_win:getCurIndex()== MarketTabConst.gold_market then
            self:sender23500(self.market_win:getCurSonIndex())
            self:sender23520()
        end
    end
end

--出售金币市场物品
function MarketController:sender23502( id,num )
    local protocal ={}
    protocal.id = id
    protocal.num = num
    self:SendProtocal(23502,protocal)
end

function MarketController:handle23502( data )
    if data.flag == 1 then
        self.dispather:Fire(MarketEvent.Gold_Sell_Success)
    end
end

--更新金币市场分类的数据
function MarketController:sender23518( catalg )
    local protocal ={}
    protocal.catalg = catalg
    self:SendProtocal(23518,protocal)
end

function MarketController:handle23518( data )
    --Debug.info(data)
end

--金币市场获取玩家限购数据
function MarketController:sender23520(  )
    local protocal ={}
    self:SendProtocal(23520,protocal)
end

function MarketController:handle23520( data )
    --Debug.info(data)
    self.model:setLimitList(data.limit_data)
end


----银币
--银币市场物品上架
function MarketController:sender23504( package_type,item_id,num,percent,cell_id )
    local protocal ={}
    protocal.package_type = package_type
    protocal.item_id = item_id
    protocal.num = num
    protocal.percent = percent
    protocal.cell_id = cell_id
    self:SendProtocal(23504,protocal)
end

function MarketController:handle23504( data )
    --Debug.info(data)
end

--购买银币市场物品
function MarketController:sender23505(type,id,num)
    local protocal ={}
    protocal.type = type
    protocal.id = id
    protocal.num = num 
    self:SendProtocal(23505,protocal) 
end

function MarketController:handle23505( data )
    self.dispather:Fire(MarketEvent.Sliver_Market_Buy_Success,data)
end

--银币市场物品下架
function MarketController:sender23506( cell_id )
    local protocal ={}
    protocal.cell_id = cell_id
    self:SendProtocal(23506,protocal) 
end

function MarketController:handle23506( data )
    --Debug.info(data)
end

--获取银币市场摊位信息
function MarketController:sender23507(  )
    local protocal ={}
    self:SendProtocal(23507,protocal) 
end

function MarketController:handle23507( data )
    --Debug.info(data)
    self.model:setSliverShop(data)
    self.dispather:Fire(MarketEvent.Sliver_Shop_Data)
end

--查询银币市场物品价格
function MarketController:sender23508(item_base_id  )
    local protocal ={}
    protocal.item_base_id = item_base_id
    self:SendProtocal(23508,protocal) 
end

function MarketController:handle23508( data )
    --Debug.info(data)
    self.dispather:Fire(MarketEvent.Sliver_Price,data)
end

--银币市场刷新/获取数据
function MarketController:sender23509( refresh_type )
    local protocal ={}
    protocal.refresh_type = refresh_type
    self:SendProtocal(23509,protocal) 
end

function MarketController:handle23509( data )
    --Debug.info(data)
    self.dispather:Fire(MarketEvent.Update_Sliver_Market,data)
end

--银币市场提取摊位收益
function MarketController:sender23511( cell_id )
    local protocal ={}
    protocal.cell_id = cell_id
    self:SendProtocal(23511,protocal) 
    print("=====23511====",cell_id)
end

function MarketController:handle23511( data )
    Debug.info(data)
end

--银币市场开放摊位
function MarketController:sender23512(  )
    local protocal ={}
    self:SendProtocal(23512,protocal) 
end

function MarketController:handle23512( data )
    
end

--银币市场重新上架
function MarketController:sender23513(cell_id,percent,num)
    local protocal ={}
    protocal.cell_id = cell_id
    protocal.percent = percent
    protocal.num = num
    self:SendProtocal(23513,protocal) 
end

function MarketController:handle23513( data )
    --Debug.info(data)
end

--银币市场一键操作
function MarketController:sender23514( type )
    local protocal ={}
    protocal.type = type
    self:SendProtocal(23514,protocal) 
end

function MarketController:handle23514( data )
    --Debug.info(data)
end

--查询市场、商城物品价格
function MarketController:sender23516( base_ids )
    local protocal = {}
    protocal.base_ids = base_ids
    self:SendProtocal(23516,protocal)
end

function MarketController:handle23516( data )
    --Debug.info(data)
    for k,v in pairs(data.market_price) do
        self.price_list[v.base_id] = v
    end
    self.dispather:Fire(MarketEvent.Gold_Sell_Price)
end

function MarketController:getPriceList(  )
    return self.price_list or {}
end

function MarketController:getPriceItemByBid(bid)
    return self.price_list[bid]
end

--==============================--
--desc:打开市场界面
--time:2018-07-30 10:14:53
--@status:
--@index:
--@sub_index:
--@bid:需求的物品bid
--@need_list:需求的物品列表,包含了 {bid= k, need_num = treasure.need_num}
--@return 
--==============================--
function MarketController:openMainWindow( status,index, sub_index,bid, need_list)
	if status then 
        local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.mall) 
        if build_vo and build_vo.is_lock then
            message(build_vo.desc)
            return
        end

        if not self.market_win  then
            self.market_win = MarketMainWindow.New()
        end
        index = index or MarketTabConst.gold_market
        self.need_bid = bid
        self.need_item_list = need_list
        sub_index = sub_index or 1
        self.market_win:open(index,sub_index,bid)
    else
        if self.market_win then 
            self.market_win:close()
            self.market_win = nil
        end
    end
end

--==============================--
--desc:引导需要
--time:2018-07-17 10:19:59
--@return 
--==============================--
function MarketController:getMarketRoot()
    if self.market_win then
        return self.market_win.root_wnd
    end
end

--==============================--
--desc:引导需要
--time:2018-07-17 10:40:02
--@return 
--==============================--
function MarketController:getMarketBuyRoot()
    if self.market_buy then
        return self.market_buy.root_wnd
    end
end

function MarketController:getMarketMainWin(  )
    return self.market_win
end

--返回需求的物品bid
function MarketController:getNeedBid(  )
    return self.need_bid
end

--==============================--
--desc:检查这个是不是当前需要的物品
--time:2018-07-30 10:16:53
--@bid:
--@return 
--==============================--
function MarketController:checkIsNeedItem(bid)
    if bid == nil then return false end
    local backpack_model = BackpackController:getInstance():getModel()
    
    if self.need_item_list then
        for i,v in ipairs(self.need_item_list) do
            if type(v) == "table" then
                if v.bid and v.bid == bid then
                    local sum = backpack_model:getBackPackItemNumByBid(bid)
                    if sum < (v.need_num or 0) then
                        return true
                    end
                end
            else
                if v == bid then 
                    return true 
                end
            end
        end
    else
        if self.need_bid ~= nil and self.need_bid == bid then 
            return true
        end
    end
    
    return false
end

--打开市场购买/出售界面 
function MarketController:openBuyOrSellWindow( status,type,data )
   if status then 
        if not self.market_buy  then
            self.market_buy = MarketBuyWindow.New()
        end
        self.market_buy:open(type,data)
    else
        if self.market_buy then 
            self.market_buy:close()
            self.market_buy = nil
        end
    end 
end

--打开银币摆摊窗口
function MarketController:openSliverGroundingWindow( status,data,cell_id )
    if status then 
        if not self.sliver_grounding  then
            self.sliver_grounding = SliverGroundingWindow.New()
        end
        self.sliver_grounding:open(data,cell_id)
    else
        if self.sliver_grounding then 
            self.sliver_grounding:close()
            self.sliver_grounding = nil
        end
    end 
end

--打开银币摆摊更改出售界面
function MarketController:openSliveSellWindow( status,data )
    if status then 
        if not self.sliver_sell  then
            self.sliver_sell = SliverSellWindow.New()
        end
        self.sliver_sell:open(data)
    else
        if self.sliver_sell then 
            self.sliver_sell:close()
            self.sliver_sell = nil
        end
    end 
end

--打开银币摆摊一键上架界面
function MarketController:openSliverOneUpWindow( status,data )
    if status then 
        if not self.sliver_oneup  then
            self.sliver_oneup = SliverOneUpWindow.New()
        end
        self.sliver_oneup:open(data)
    else
        if self.sliver_oneup then 
            self.sliver_oneup:close()
            self.sliver_oneup = nil
        end
    end 
end


function MarketController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end