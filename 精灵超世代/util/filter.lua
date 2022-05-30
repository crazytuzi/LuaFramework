
function createGreyFilter()
    -- body
    return {0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0, 0, 0, 1, 0}
end

-- 红色
function createRed()
    return {1,0,0,0.42,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0}
end

--色彩饱和度n:
function createSaturationFilter(n)
    -- body
    return {0.199 * (1 - n) + n, 0.017 * (1 - n), 0.114 * (1 - n), 0, 0, 
    0.199 * (1 - n), 0.017 * (1 - n) + n, 0.114 * (1 - n), 0, 0, 
    0.199 * (1 - n), 0.017 * (1 - n), 0.114 * (1 - n) + n, 0, 0, 
    0, 0, 0, 1, 0}
end

--对比度n:
function createContrastFilter( n )
    -- body
    return {n, 0, 0, 0, 128 * (1 - n), 0, n, 0, 0, 128 * (1 - n), 0, 0, n, 0, 128 * (1 - n), 0, 0, 0, 1, 0}
end

--亮度n:
function createBrightnessFilter( n )
    -- body
    return {1, 0, 0, 0, n, 0, 1, 0, 0, n, 0, 0, 1, 0, n, 0, 0, 0, 1, 0}
end

--颜色反相
function createInversionFilter()
    -- body
    return {-1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0}
end

-- 银白
function createWhite()
    return {1,0.1,0,0,0,0,1,0.1,0,0,0,0,1,0.1,0,0,0,0,0.7,0}
end

--------  怪物效果  --------
-- 幽灵滤镜
function createGhost()
    return {1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0.3,0.31,0.71,0.3,0}
end

-- 幽灵2
function createGhost2()
    return {0.66,0,0,0,0,0,0.6,0,0,0,0,0,1,0,0,0,0,0,0.44,0}
end

-- 魔化
function createMagic()
end

----------------------------
-- 色相偏移
--0-360
function createHueFilter(n)

p1 = math.cos(n * 3.1415926/ 180)
p2 = math.sin(n * 3.1415926 / 180)
p4 = 0.213;
p5 = 0.715;
p6 = 0.072;
 return {p4 + p1 * (1 - p4) + p2 * (0 - p4), p5 + p1 * (0 - p5) + p2 * (0 - p5), p6 + p1 * (0 - p6) + p2 * (1 - p6), 0, 0, 
             p4 + p1 * (0 - p4) + p2 * 0.143, p5 + p1 * (1 - p5) + p2 * 0.14, p6 + p1 * (0 - p6) + p2 * -0.283, 0, 0, 
             p4 + p1 * (0 - p4) + p2 * (0 - (1 - p4)), p5 + p1 * (0 - p5) + p2 * p5, p6 + p1 * (1 - p6) + p2 * p6, 0, 0, 
             0, 0, 0, 1, 0}
 end

 --冰冻
 function createIceFilter( ... )
     -- body
     return {1,0,0,0,18,0,1,0,0,166,0,0,1,0,245,0,0,0,1,0}
 end