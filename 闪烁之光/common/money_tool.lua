MoneyTool = MoneyTool or {}

function MoneyTool.GetMoneyString(value, is_symbol)
   is_symbol = (is_symbol == nil) and true or is_symbol
   if value == nil then
       return 0
   end
   if value < 100000 then
       if is_symbol then
           return MoneyTool.moneyFormat(value)
       else
           return value
       end
   elseif value < 100000000 then
       value = math.floor(value * 0.0001)
       if is_symbol then
           return string.format(TI18N("%s万"), MoneyTool.moneyFormat(value))
       else
           return string.format(TI18N("%s万"), value)
       end
   else
       
       if is_symbol then
          value = math.modf(value * 0.0000001)
          local value1, value2 = math.modf(value/10)
          if value2 == 0 then
              return string.format(TI18N("%s亿"), MoneyTool.moneyFormat(value1))
          else
              return string.format(TI18N("%s.%s亿"), MoneyTool.moneyFormat(value1), value2*10)
          end
       else
           value = math.modf(value * 0.0000001)
           return string.format(TI18N("%s亿"), value/10)
       end
   end
   return value
end


--价钱里面加上逗号
function MoneyTool.moneyFormat(value)
    local sign = ""
    if value < 0 then
        sign = "-"
        value = value * (-1)
    end
    if value < 1000 then
        return tostring(value)
    end
    local arr = MoneyTool.split(tostring(value),"")
    local n = table.getn(arr)
    local i = math.mod(n,3)
    if i == 0 then
        i = 4
    else
        i = i + 1
    end
    while i < n do
        table.insert(arr,i,",")
        i = i + 4
        n = n + 1
    end
    return sign .. MoneyTool.join(arr,"")
end

--[[带有逗号的money字符串
-- @param is_symbol 是否加逗号
-- ]]
function MoneyTool.getMoneyString2(value, is_symbol)
    is_symbol = (is_symbol == nil) and true or is_symbol
    if value == nil then
        return 0
    end
    if is_symbol then
        return MoneyTool.moneyFormat(value)
    else
        return value
    end

--    is_symbol = (is_symbol == nil) and true or is_symbol
--    if value == nil then
--        return 0
--    end
--    if value < 10000 then
--        if is_symbol then
--            return MoneyTool.moneyFormat(value)
--        else
--            return value
--        end
--    elseif value < 100000000 then
--        value = value * 0.0001
--        value = value-value%0.1
--        if is_symbol then
--            return string.format("%s万", MoneyTool.moneyFormat(value))
--        else
--            return string.format("%s万", value)
--        end
--    else
--        value = math.modf(value * 0.00000001)
--        if is_symbol then
--            return string.format("%s亿", MoneyTool.moneyFormat(value))
--        else
--            return string.format("%s亿", value)
--        end
--    end
--    return value
end

function MoneyTool.split(source_str,split_str)
    if string.len(split_str) == 0 then
        local arr = {}
        for i = 1, string.len(source_str) do
            table.insert(arr,string.sub(source_str, i, i))
        end
        return arr
    else
        return Split(source_str,split_str)
    end
end

function MoneyTool.join(source_table, split_str)
    if string.len(split_str) == 0 then
        local fmt = "%s"
        for i = 2, table.getn(source_table) do
            fmt = fmt .. split_str .. "%s"
        end
        return string.format(fmt, unpack(source_table))
    else
        return Join(source_table, split_str)
    end
end

function MoneyTool.GetMoneyWanString(value)
    if value == nil then
        return 0
    end
    if value < 100000 then
        return value
    else
        value = math.floor(value * 0.0001)
        return string.format(TI18N("%s万"), value)
    end
    return value
 end