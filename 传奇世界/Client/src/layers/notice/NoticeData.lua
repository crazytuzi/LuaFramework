--[[ 公告数据存储  ]]--
DATA_Notice = {}
local _data = nil
local isShow = false      --是否展示过
function DATA_Notice:setData( sevData )
    -- isShow = false    --再次刷新数据也不弹出
    local num = tonumber( sevData:popChar() )
    _data = {}
    for i = 1 , num do
        _data[ #_data + 1 ] = {}
        _data[ #_data ].type =  sevData:popChar()
        _data[ #_data ].title =  sevData:popString()
        local tempStr = sevData:popString() 
        _data[ #_data ].content = { tempStr }
    end
    -- _data = { 
    --         { type = 1 , title = "" , content = { "官方客服Q" , "官方24小时客服电话4001109595995" , "---------------------------------" } } , 
    --         { type = 2 , title = "开服活动爽翻天，百万豪杰礼送不停" , content = { "充值就送垃圾相恋" , "活动范围:全区" , "活动内容：充一毛送一毛，就是这样" } } , 
    --         { type = 2 , title = "开服活动爽翻天，百万豪杰礼送不停" , content = { "充值就送垃圾相恋" , "活动范围:全区" , "活动内容：充一毛送一毛，就是这样" } } , 
    --         { type = 2 , title = "开服活动爽翻天，百万豪杰礼送不停" , content = { "充值就送垃圾相恋" , "活动范围:全区" , "活动内容：充一毛送一毛，就是这样" } } , 
    --         { type = 2 , title = "开服活动爽翻天，百万豪杰礼送不停" , content = { "充值就送垃圾相恋" , "活动范围:全区" , "活动内容：充一毛送一毛，就是这样" } } , 
    --       }
end

function DATA_Notice:setHttpData(title, content)
    isShow = false
    _data = {}
    _data[1] = {title=title, content={content}}
end

function DATA_Notice:getData( )
  return _data
end

function DATA_Notice:setFlag()
    isShow = true    
end

function DATA_Notice:getFlag()
  return isShow
end


return DATA_Notice