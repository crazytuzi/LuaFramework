-- @author pwj
-- @date 2018年1月6日,星期六

FashionDiscountModel = FashionDiscountModel or BaseClass(BaseModel)

function FashionDiscountModel:__init()
    self.fashionList = {{}, {}}             --时装信息[1] 为匹配时装   [2]为非匹配时装

end

function FashionDiscountModel:__delete()
end

function FashionDiscountModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = FashionDiscountWindow.New(self)
    end
    self.mainWin:Open(args)
end

function FashionDiscountModel:OpenDetailWindow(args)
    if self.detailWin == nil then
        self.detailWin = FashionDiscountDetailWindow.New(self)
    end
    self.detailWin:Open(args)
end

function FashionDiscountModel:CloseMainWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function FashionDiscountModel:CloseDetailWindow()
    WindowManager.Instance:CloseWindow(self.detailWin)
end

function FashionDiscountModel:InitFashionList()
    --初始化前三时装信息
    for i,v in ipairs(FashionDiscountManager.Instance.fashionData.fashion_list) do 
        if v ~= nil and v.fashion_info ~= nil then
            local goodId = (v.goods_id - 1) % 3 + 1
            self.fashionList[1][goodId] = { }
            self.fashionList[2][goodId] = { }
            for k,c in ipairs (v.fashion_info) do
                if c.classes == 0 or c.classes == RoleManager.Instance.RoleData.classes then
                    if c.sex == RoleManager.Instance.RoleData.sex or c.sex == 2 then
                        table.insert(self.fashionList[1][goodId],c)
                    else
                        table.insert(self.fashionList[2][goodId],c)
                    end
                end
            end
        end
    end
    for i =1, 3 do 
        if self.fashionList[1][i] ~= nil then 
            table.sort(self.fashionList[1][i],function(a,b)
                if a.origin_price ~= b.origin_price then
                    return a.origin_price < b.origin_price
                else
                    return false
                end
            end)
        end
        if self.fashionList[1][i] ~= nil then 
            table.sort(self.fashionList[2][i],function(a,b)
                if a.origin_price ~= b.origin_price then
                    return a.origin_price < b.origin_price
                else
                    return false
                end
            end)
        end
    end 
    --BaseUtils.dump(self.fashionList,"fashionList链表结构")
end


