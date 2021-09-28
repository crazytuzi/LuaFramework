--[[

container_type   容器类型 1 背包 2 装备栏 
product_type     物品类型 对应  product.lua 的 type

--]]

local tipButtonContainer = {
    [1] =
    {
        button_label = '使用',
        -- 按钮文本
        funName = 'useProduct',
        -- 点击按钮回调方法名
        conditions =
        {
            { container_type = 1, product_type = 4 },
            { container_type = 1, product_type = 5 },
			{ container_type = 1, product_type = 6 },
            { container_type = 1, product_type = 10 }
        },
    },

    [2] =
    {
        button_label = '穿戴',
        -- 按钮文本
        funName = 'dressEq',
        -- 点击按钮回调方法名
        conditions =
        {
            { container_type = 1, product_type = 1 }
        },
    },
    [3] =
    {
        button_label = '卸下',
        -- 按钮文本
        funName = 'undressEq',
        -- 点击按钮回调方法名
        conditions =
        {
            { container_type = 2, product_type = 1 }
        },
    },
    [4] =
    {
        button_label = '出售',
        -- 按钮文本
        funName = 'sellPruduct',
        -- 点击按钮回调方法名
        conditions =
        {
            { container_type = 1, product_type = 1 },
            { container_type = 1, product_type = 2 },
            { container_type = 1, product_type = 3 },
            { container_type = 1, product_type = 4 },
            { container_type = 1, product_type = 5 },
            { container_type = 1, product_type = 6 },
            { container_type = 1, product_type = 7 },
			{ container_type = 1, product_type = 9 },
            { container_type = 1, product_type = 10 }			
        },
    },	
}
return tipButtonContainer