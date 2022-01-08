--
-- Author: MiYu
-- Date: 2014-02-13 14:36:02
--
me = me or {}

FLT_EPSILON = FLT_EPSILON or 1.192092896e-7

if CCPoint then return end

function me.clampf(value, min_inclusive, max_inclusive)
    -- body
    if min_inclusive > max_inclusive then
        min_inclusive, max_inclusive = max_inclusive, min_inclusive
    end

    if value < min_inclusive then
        return min_inclusive
    elseif value < max_inclusive then
        return value
    else
        return max_inclusive
    end
end
clampf = me.clampf

--Point
me.pointMT = me.pointMT or {}
__mePointMT__ = me.pointMT
me.pointMT.__index = me.pointMT
me.pointMT.__tostring = function (t) return string.format('{point:x=%.2f, y=%.2f}', t.x, t.y) end

function me.p(_x,_y)
    if nil == _y then
         return setmetatable({ x = _x.x, y = _x.y }, __mePointMT__)
    else
         return setmetatable({ x = _x, y = _y }, __mePointMT__)
    end
end
CCPointMake = me.p 
ccp = me.p
CCPoint = me.p

function me.pAdd(pt1,pt2)
    return ccp(pt1.x + pt2.x, pt1.y + pt2.y)
end
ccpAdd = me.pAdd

function me.pSub(pt1,pt2)
    return ccp(pt1.x - pt2.x, pt1.y - pt2.y)
end
ccpSub = me.pSub

function me.pMult(pt1,factor)
    return ccp(pt1.x * factor, pt1.y * factor)
end
ccpMult = me.pMult

function me.pDiv(pt1, factor)
    if factor == 0 then 
        print("[Lua Error] cpp / use o as div")
        return pt1
    end
    return ccp(pt1.x / factor, pt1.y / factor)
end
ccpDiv = me.pDiv

function me.pNeg(pt)
    return ccp(-pt1.x, -pt1.y)
end
ccpNeg = me.pNeg

function me.pEquals(pt1, pt2)
    return pt1.x == pt2.x and pt1.y == pt2.y
end
ccpEquals = me.pEquals

function me.pMidpoint(pt1, pt2)
    return ccp((pt1.x + pt2.x) / 2.0, ( pt1.y + pt2.y) / 2.0)
end
ccpMidpoint = me.pMidpoint

function me.pForAngle(a)
    return ccp(math.cos(a), math.sin(a))
end
ccpForAngle = me.pForAngle

function me.pGetLength(pt)
    return math.sqrt( pt.x * pt.x + pt.y * pt.y )
end
ccpLength = me.pGetLength

function me.pNormalize(pt)
    local length = me.pGetLength(pt)
    if 0 == length then
        return ccp(1.0, 0.0)
    end

    return ccp(pt.x / length, pt.y / length)
end
ccpNormalize = me.pNormalize

function me.pCross(self,other)
    return self.x * other.y - self.y * other.x
end
ccpCross = me.pCross

function me.pDot(self,other)
    return self.x * other.x + self.y * other.y
end
ccpDot = me.pDot

function me.pToAngleSelf(self)
    return math.atan2(self.y, self.x)
end
ccpToAngle = me.pToAngleSelf

function me.pGetAngle(self,other)
    local a2 = me.pNormalize(self)
    local b2 = me.pNormalize(other)
    local angle = math.atan2(me.pCross(a2, b2), me.pDot(a2, b2) )
    if angle < FLT_EPSILON then
        return 0.0
    end

    return angle
end
ccpAngleSigned = me.pGetAngle

ccpAngle = function(a, b)
    local angle = math.acos(me.pDot(me.pNormalize(a), me.pNormalize(b)));
    if math.abs(angle) < FLT_EPSILON then
        return 0.0
    end
    return angle
end

function me.pGetDistance(startP,endP)
    return me.pGetLength(me.pSub(startP,endP))
end
ccpDistance = me.pGetDistance

function me.pIsLineIntersect(A, B, C, D, s, t)
    if ((A.x == B.x) and (A.y == B.y)) or ((C.x == D.x) and (C.y == D.y))then
        return false, s, t
    end

    local BAx = B.x - A.x
    local BAy = B.y - A.y
    local DCx = D.x - C.x
    local DCy = D.y - C.y
    local ACx = A.x - C.x
    local ACy = A.y - C.y

    local denom = DCy * BAx - DCx * BAy
    s = DCx * ACy - DCy * ACx
    t = BAx * ACy - BAy * ACx

    if (denom == 0) then
        if (s == 0 or t == 0) then
            return true, s , t
        end
        return false, s, t
    end
    
    s = s / denom
    t = t / denom

    return true, s, t
end
ccpLineIntersect = me.pIsLineIntersect

function me.pPerp(pt)
    return ccp(-pt.y, pt.x)
end
ccpPerp = me.pPerp

function me.pRPerp(pt)
    return ccp(pt.y, -pt.x)
end
ccpRPerp = me.pRPerp

function me.pProject(pt1, pt2)
    return ccp(pt2.x * (me.pDot(pt1,pt2) / me.pDot(pt2,pt2)), pt2.y * (me.pDot(pt1,pt2) / me.pDot(pt2,pt2)))
end
ccpProject = me.pProject

function me.pRotate(pt1, pt2)
    return ccp(pt1.x * pt2.x - pt1.y * pt2.y, pt1.x * pt2.y + pt1.y * pt2.x)
end
ccpRotate = me.pRotate

function me.pUnrotate(pt1, pt2)
    return ccp(pt1.x * pt2.x + pt1.y * pt2.y, pt1.y * pt2.x - pt1.x * pt2.y)
end
ccpUnrotate = me.pUnrotate

--Calculates the square length of pt
function me.pLengthSQ(pt)
    return me.pDot(pt,pt)
end
ccpLengthSQ = me.pLengthSQ

--Calculates the square distance between pt1 and pt2
function me.pDistanceSQ(pt1,pt2)
    return me.pLengthSQ(me.pSub(pt1,pt2))
end
ccpDistanceSQ = me.pDistanceSQ

function me.pGetClampPoint(pt1,pt2,pt3)
    return ccp(me.clampf(pt1.x, pt2.x, pt3.x), me.clampf(pt1.y, pt2.y, pt3.y))
end
ccpClamp = me.pGetClampPoint

function me.pFromSize(sz)
    return ccp(sz.width, sz.height)
end
ccpFromSize = me.pFromSize

function me.pLerp(pt1,pt2,alpha) 
    return me.pAdd(me.pMult(pt1, 1.0 - alpha), me.pMult(pt2,alpha) )
end
ccpLerp = me.pLerp

function me.pFuzzyEqual(pt1,pt2,variance)
    if (pt1.x - variance <= pt2.x) and (pt2.x <= pt1.x + variance) and (pt1.y - variance <= pt2.y) and (pt2.y <= pt1.y + variance) then
        return true
    else
        return false
    end
end
ccpFuzzyEqual = me.pFuzzyEqual

function me.pRotateByAngle(pt1, pt2, angle)
    return me.pAdd(pt2, me.pRotate( me.pSub(pt1, pt2),me.pForAngle(angle)))    
end
ccpRotateByAngle = me.pRotateByAngle

function me.pIsSegmentIntersect(pt1,pt2,pt3,pt4)
    local s,t,ret = 0,0,false
    ret,s,t =me.pIsLineIntersect(pt1, pt2, pt3, pt4,s,t)
    
    if ret and  s >= 0.0 and s <= 1.0 and t >= 0.0 and t <= 0.0 then
        return true;
    end

    return false
end
ccpSegmentIntersect = me.pIsSegmentIntersect

function me.pGetIntersectPoint(pt1,pt2,pt3,pt4)
    local s,t, ret = 0,0,false
    ret,s,t = me.pIsLineIntersect(pt1,pt2,pt3,pt4,s,t) 
    if ret then
        return me.p(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y))
    else
        return me.p(0,0)
    end
end
ccpIntersectPoint = me.pGetIntersectPoint

me.pointMT.__add                    = me.pAdd
me.pointMT.__sub                    = me.pSub
me.pointMT.__mul                    = me.pMult
me.pointMT.__div                    = me.pDiv
me.pointMT.__eq                     = me.pEquals
me.pointMT.__unm                    = me.pNeg
me.pointMT.__len                    = me.pGetLength

me.pointMT.midpoint                 = me.pMidpoint
me.pointMT.forAngle                 = me.pForAngle
me.pointMT.length                   = me.pGetLength
me.pointMT.normalize                = me.pNormalize
me.pointMT.cross                    = me.pCross
me.pointMT.dot                      = me.pDot
me.pointMT.toAngle                  = me.pToAngleSelf
me.pointMT.getAngle                 = me.pGetAngle
me.pointMT.lineIntersect            = me.pIsLineIntersect
me.pointMT.perp                     = me.pPerp
me.pointMT.rPerp                    = me.pRPerp
me.pointMT.project                  = me.pProject
me.pointMT.rotate                   = me.pRotate
me.pointMT.unRotate                 = me.pUnrotate
me.pointMT.lengthSQ                 = me.pLengthSQ
me.pointMT.clamp                    = me.pGetClampPoint
me.pointMT.lerp                     = me.pLerp
me.pointMT.fuzzyEqual               = me.pFuzzyEqual
me.pointMT.rotateByAngle            = me.pRotateByAngle
me.pointMT.isSegmentIntersect       = me.pIsSegmentIntersect
me.pointMT.intersectPoint           = me.pGetIntersectPoint

--Size
function me.size( _width,_height )
    return { width = _width, height = _height }
end
CCSizeMake = me.size 
CCSize = me.size
ccs = me.size

function me.sEquals(s1, s2)
    return s1.width == s2.width and s1.height == s2.height
end
sizeEquals = me.sEquals

--Rect

me.rectMT = me.rectMT or {}
__meRectMT__ = me.rectMT
me.rectMT.__index = me.rectMT
me.rectMT.__tostring = function (t) return string.format('{rect:x=%.2f, y=%.2f, width=%.2f, height=%.2f}', t.origin.x, t.origin.y, t.size.width, t.size.height) end
function me.rect(_x,_y,_width,_height)
    local rect = setmetatable({}, me.rectMT)
    rect.size = ccs(_width,_height)
    rect.origin = ccp(_x,_y)
    return rect
end
CCRectMake = me.rect 
CCRect = me.rect
ccr = me.rect

function me.rectEqualToRect(rect1,rect2)
    if ((rect1.origin.x >= rect2.origin.x) or (rect1.origin.y >= rect2.origin.y) or
        ( rect1.origin.x + rect1.size.width <= rect2.origin.x + rect2.size.width) or
        ( rect1.origin.y + rect1.size.height <= rect2.origin.y + rect2.size.height)) then
        return false
    end
    return true
end

function me.rectGetMaxX(rect)
    return rect.origin.x + rect.size.width
end

function me.rectGetMidX(rect)
    return rect.origin.x + rect.size.width / 2.0
end

function me.rectGetMinX(rect)
    return rect.origin.x
end

function me.rectGetMaxY(rect)
    return rect.origin.y + rect.size.height
end

function me.rectGetMidY(rect)
    return rect.origin.y + rect.size.height / 2.0
end

function me.rectGetMinY(rect)
    return rect.origin.y
end

function me.rectEquals(rect1, rect2)
    return math.abs(rect1.origin.x - rect2.origin.x) < FLT_EPSILON 
        and math.abs(rect1.origin.y - rect2.origin.y) < FLT_EPSILON 
        and math.abs(rect1.size.width - rect2.size.width) < FLT_EPSILON 
        and math.abs(rect1.size.height - rect2.size.height) < FLT_EPSILON 
end

function me.rectContainsPoint( rect, point )
    local ret = false
    if (point.x >= rect.origin.x) and (point.x <= rect.origin.x + rect.size.width) and
       (point.y >= rect.origin.y) and (point.y <= rect.origin.y + rect.size.height) then
        ret = true
    end
    return ret
end

function me.rectIntersectsRect( rect1, rect2 )
    local intersect = not ( rect1.origin.x > rect2.origin.x + rect2.size.width or
                    rect1.origin.x + rect1.size.width < rect2.origin.x         or
                    rect1.origin.y > rect2.origin.y + rect2.size.height        or
                    rect1.origin.y + rect1.size.height < rect2.origin.y )
    return intersect
end

function me.rectUnion( rect1, rect2 )
    local rect = me.rect(0, 0, 0, 0)
    rect.origin.x = math.min(rect1.origin.x, rect2.origin.x)
    rect.origin.y = math.min(rect1.origin.y, rect2.origin.y)
    rect.size.width = math.max(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width) - rect.origin.x
    rect.size.height = math.max(rect1.origin.y + rect1.size.height, rect2.origin.y + rect2.size.height) - rect.origin.y
    return rect
end

function me.rectIntersection( rect1, rect2 )
    local intersection = me.rect(
        math.max(rect1.origin.x, rect2.origin.x),
        math.max(rect1.origin.y, rect2.origin.y),
        0, 0)
    intersection.size.width = math.min(rect1.origin.x + rect1.size.width, rect2.origin.x + rect2.size.width) - intersection.origin.x
    intersection.size.height = math.min(rect1.origin.y + rect1.size.height, rect2.origin.y + rect2.size.height) - intersection.origin.y
    return intersection
end

me.rectMT.getMinX           = me.rectGetMinX
me.rectMT.getMidX           = me.rectGetMidX
me.rectMT.getMaxX           = me.rectGetMaxX
me.rectMT.getMinY           = me.rectGetMinY
me.rectMT.getMidY           = me.rectGetMidY
me.rectMT.getMaxY           = me.rectGetMaxY
me.rectMT.equals            = me.rectEquals
me.rectMT.containsPoint     = me.rectContainsPoint
me.rectMT.containsRect      = me.rectEqualToRect
me.rectMT.intersectsRect    = me.rectIntersectsRect
me.rectMT.unionRect         = me.rectUnion
me.rectMT.intersectionRect  = me.rectIntersection

--Color3B
function me.c3b( _r,_g,_b )
    return { r = _r, g = _g, b = _b }
end

ccc3 = me.c3b

ccWHITE      = ccc3(255, 255, 255)
ccYELLOW     = ccc3(255, 255,   0)
ccBLUE       = ccc3(  0,   0, 255)
ccGREEN      = ccc3(  0, 255,   0)
ccRED        = ccc3(255,   0,   0)
ccMAGENTA    = ccc3(255,   0, 255)
ccBLACK      = ccc3(  0,   0,   0)
ccORANGE     = ccc3(255, 127,   0)
ccGRAY       = ccc3(166, 166, 166)

me.WHITE     = ccWHITE  
me.YELLOW    = ccYELLOW 
me.BLUE      = ccBLUE   
me.GREEN     = ccGREEN  
me.RED       = ccRED    
me.MAGENTA   = ccMAGENTA
me.BLACK     = ccBLACK  
me.ORANGE    = ccORANGE 
me.GRAY      = ccGRAY   

--Color4B
function me.c4b( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end

--Color4F
function me.c4f( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end

--Vertex2F
function me.vertex2F(_x,_y)
    return { x = _x, y = _y }
end

--Vertex3F
function me.Vertex3F(_x,_y,_z)
    return { x = _x, y = _y, z = _z }
end

--Tex2F
function me.tex2F(_u,_v)
    return { u = _u, v = _v }
end

--PointSprite
function me.PointSprite(_pos,_color,_size)
    return { pos = _pos, color = _color, size = _size }
end

--Quad2
function me.Quad2(_tl,_tr,_bl,_br)
    return { tl = _tl, tr = _tr, bl = _bl, br = _br }
end

--Quad3
function me.Quad3(_tl, _tr, _bl, _br)
    return { tl = _tl, tr = _tr, bl = _bl, br = _br }
end

--V2F_C4B_T2F
function me.V2F_C4B_T2F(_vertices, _colors, _texCoords)
    return { vertices = _vertices, colors = _colors, texCoords = _texCoords }
end

--V2F_C4F_T2F
function me.V2F_C4F_T2F(_vertices, _colors, _texCoords)
    return { vertices = _vertices, colors = _colors, texCoords = _texCoords }
end

--V3F_C4B_T2F
function me.V3F_C4B_T2F(_vertices, _colors, _texCoords)
    return { vertices = _vertices, colors = _colors, texCoords = _texCoords }
end

--V2F_C4B_T2F_Quad
function me.V2F_C4B_T2F_Quad(_bl, _br, _tl, _tr)
    return { bl = _bl, br = _br, tl = _tl, tr = _tr }
end

--V3F_C4B_T2F_Quad
function me.V3F_C4B_T2F_Quad(_tl, _bl, _tr, _br)
    return { tl = _tl, bl = _bl, tr = _tr, br = _br }
end

--V2F_C4F_T2F_Quad
function me.V2F_C4F_T2F_Quad(_bl, _br, _tl, _tr)
    return { bl = _bl, br = _br, tl = _tl, tr = _tr }
end

--T2F_Quad
function me.T2F_Quad(_bl, _br, _tl, _tr)
    return { bl = _bl, br = _br, tl = _tl, tr = _tr }
end

--AnimationFrameData
function me.AnimationFrameData( _texCoords, _delay, _size)
    return { texCoords = _texCoords, delay = _delay, size = _size }
end

--PhysicsMaterial
function me.PhysicsMaterial(_density, _restitution, _friction)
	return { density = _density, restitution = _restitution, friction = _friction }
end


