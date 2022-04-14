---
---Author: HongYun
---Date: 2019/9/18 10:35:51
---

ScoreShopModel = ScoreShopModel or class('ScoreShopModel', BaseModel)
local ScoreShopModel = ScoreShopModel

function ScoreShopModel:ctor()
    ScoreShopModel.Instance = self

    self:Reset()

    self.mallDataList = {} --商品列表

    self.curSelectItem = nil --当前选中商品

    self:InitMallDatas()
    
end

function ScoreShopModel:Reset()
   
end

function ScoreShopModel.GetInstance()
    if ScoreShopModel.Instance == nil then
        ScoreShopModel.new()
    end
    return ScoreShopModel.Instance
end

--初始化商品列表
function ScoreShopModel:InitMallDatas(  )
    for k, v in pairs(Config.db_mall) do
        if v.id >= 70000 and v.id < 80000 then
            table.insert(self.mallDataList, v);
        end
    end

    table.sort(self.mallDataList, OrderCompareFun);
end

