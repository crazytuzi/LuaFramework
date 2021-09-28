local ColorShaderManager = class("ColorShaderManager")

function ColorShaderManager:ctor()
    self._shaders = {}
end


function ColorShaderManager:loadColors(list, func)
    local ps = {}
    for i, clr in ipairs(list) do
        self:getShaderKey(clr[1], clr[2], clr[3]) 
        
    end

    if func then
        func()
    end

 
    
end
--G_ColorShaderManager:loadColors({ {200,2,22}, {2,2,33}  } )
--G_ColorShaderManager:removeColors({ {200,2,22}, {2,2,33}  } )

function ColorShaderManager:removeColors(list)

    if list == nil then
        for k, clr in pairs(self._shaders) do
            self:remoevShaderKey(clr[1], clr[2], clr[3]) 
        end
    else
        for i, clr in ipairs(list) do
            self:remoevShaderKey(clr[1], clr[2], clr[3]) 
        end
    end



    
end


function ColorShaderManager:getShaderKey(r, g, b)
    local k = 'colorShader_' .. r .. '_' .. g .. "_" .. b

    if self._shaders[k] == nil then
        self:_createShader(k, r, g, b)
        self._shaders[k] = {r, g, b}
    end
    return k
end

function ColorShaderManager:remoevShaderKey(r, g, b)
    local k = 'colorShader_' .. r .. '_' .. g .. "_" .. b

    if self._shaders[k] ~= nil then

        CCShaderCache:sharedShaderCache():removeProgram(k)
        self._shaders[k] = nil
    end
end



--vert
local vertDesc =  [[
attribute vec4 a_position;                        
attribute vec2 a_texCoord;                         
attribute vec4 a_color;                            
                                                   
#ifdef GL_ES                                        
varying lowp vec4 v_fragmentColor;                 
varying mediump vec2 v_texCoord;                   
#else                                               
varying vec4 v_fragmentColor;                      
varying vec2 v_texCoord;                           
#endif                                              
                                                    
void main()                                        
{                                                  
    gl_Position = CC_MVPMatrix * a_position;       
    v_fragmentColor = a_color;                      
    v_texCoord = a_texCoord;                       
}                                                  
]]



function ColorShaderManager:_createShader(key, r, g, b)
    local r1 = string.format("%.02f", r/255)
    local g1 = string.format("%.02f", g/255)
    local b1 = string.format("%.02f", b/255)

    if r1 == g1 and r1 == b1 then
        --3 ge 
        g1 = g1  .. "1"
        b1 = b1  .. "2"
    elseif r1== g1 then
        g1  = g1  .. "1"
    elseif r1== b1 then
        b1  = b1  .. "1"
    elseif g1== b1 then
        g1  = b1  .. "1"
    end

    local t1 = FuncHelperUtil:getTickCount()
    local fragDesc = [[
    #ifdef GL_ES                               
    precision lowp float;                      
    #endif                                      
                                               
    varying vec4 v_fragmentColor;              
    varying vec2 v_texCoord;                    
    uniform sampler2D CC_Texture0;             
                                               
    void main()                                
    {                                           
        vec4 color = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);             
        color = vec4(color.rgb + vec3(]] .. r1 .. "," .. g1 .. "," .. b1 .. [[) * color.a, color.a);                      
        gl_FragColor = color;                                                          
    }                                          
    ]]



    FuncHelperUtil:addShaderWithKey(key, vertDesc, fragDesc)
    local t2 = FuncHelperUtil:getTickCount()
end


return ColorShaderManager