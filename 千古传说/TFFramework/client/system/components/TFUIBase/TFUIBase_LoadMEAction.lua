--[[
M_E		=	2.71828182845904523536
M_LOG2E	=	1.44269504088896340736
M_LOG10E	=	0.434294481903251827651
M_LN2		=	0.693147180559945309417
M_LN10	=	2.30258509299404568402
M_PI		=	3.14159265358979323846
M_PI_2		=	1.57079632679489661923
M_PI_4		=	0.785398163397448309616
M_1_PI		=	0.318309886183790671538
M_2_PI		=	0.636619772367581343076
M_2_SQRTPI	=	1.12837916709551257390
M_SQRT2	=	1.41421356237309504880
M_SQRT1_2	=	0.707106781186547524401

updateFuncs = {
	['Linear']			= function (nDT) 
						return nDT
					end,	
	['Sine_EaseIn']			= function (nDT) 
						return -1 * math.cos(nDT * M_PI_2) + 1
    -- m_pInner->update(-1 * cosf(nDT * (float)M_PI_2) + 1);
					end,	
	['Sine_EaseOut']		= function (nDT) 
						return sinf(nDT * M_PI_2)
    -- m_pInner->update(sinf(nDT * (float)M_PI_2));
					end,	
	['Sine_EaseInOut']		= function (nDT) 
						return -0.5 * (math.cos(M_PI * nDT) - 1)
    -- m_pInner->update(-0.5f * (cosf((float)M_PI * nDT) - 1));
					end,	
	['Quad_EaseIn']			= function (nDT) 
						return nDT
					end,	
	['Quad_EaseOut']		= function (nDT) 
						return nDT
					end,	
	['Quad_EaseInOut']		= function (nDT) 
						return nDT
					end,
	['Cubic_EaseIn']		= function (nDT) 
						return nDT
					end,	
	['Cubic_EaseOut']		= function (nDT) 
						return nDT
					end,	
	['Cubic_EaseInOut']		= function (nDT) 
						return nDT
					end,
	['Quart_EaseIn']		= function (nDT) 
						return nDT
					end,	
	['Quart_EaseOut']		= function (nDT) 
						return nDT
					end,	
	['Quart_EaseInOut']		= function (nDT) 
						return nDT
					end,
	['Quint_EaseIn']			= function (nDT) 
						return nDT
					end,	
	['Quint_EaseOut']		= function (nDT) 
						return nDT
					end,	
	['Quint_EaseInOut']		= function (nDT) 
						return nDT
					end,
	['Expo_EaseIn']			= function (nDT) 
						if nDT == 0 return 0
						else
							return math.pow(2, 10 * (nDT/1 - 1)) - 1 * 0.001
						end
    -- m_pInner->update(nDT == 0 ? 0 : math.pow(2, 10 * (nDT/1 - 1)) - 1 * 0.001f);
					end,	
	['Expo_EaseOut']		= function (nDT) 
						if nDT == 1 return 1
						else
							return -math.pow(2, -10 * nDT / 1) + 1)
						end
						return nDT
    -- m_pInner->update(nDT == 1 ? 1 : (-math.pow(2, -10 * nDT / 1) + 1));
					end,	
	['Expo_EaseInOut']		= function (nDT) 
						nDT = nDT / 0.5f;
						if (nDT < 1)
						{
						    nDT = 0.5 * math.pow(2, 10 * (nDT - 1));
						}
						else
						{
						    nDT = 0.5 * (-math.pow(2, -10 * (nDT - 1)) + 2);
						}
						return nDT
    -- nDT /= 0.5f;
    -- if (nDT < 1)
    -- {
    --     nDT = 0.5f * math.pow(2, 10 * (nDT - 1));
    -- }
    -- else
    -- {
    --     nDT = 0.5f * (-math.pow(2, -10 * (nDT - 1)) + 2);
    -- }

    -- m_pInner->update(nDT);
					end,
	['Bounce_EaseIn']		= function (nDT) 
    -- float newT = 1 - bounceTime(1 - nDT);
    -- m_pInner->update(newT);
						return nDT
					end,	
	['Bounce_EaseOut']		= function (nDT) 
    -- float newT = bounceTime(nDT);
    -- m_pInner->update(newT);
						return nDT
					end,	
	['Bounce_EaseInOut']		= function (nDT) 
    -- float newT = 0;
    -- if (nDT < 0.5f)
    -- {
    --     nDT = nDT * 2;
    --     newT = (1 - bounceTime(1 - nDT)) * 0.5f;
    -- }
    -- else
    -- {
    --     newT = bounceTime(nDT * 2 - 1) * 0.5f + 0.5f;
    -- }

    -- m_pInner->update(newT);
						return nDT
					end,
	['Circ_EaseIn']			= function (nDT) 
						return nDT
					end,	
	['Circ_EaseOut']		= function (nDT) 
						return nDT
					end,	
	['Circ_EaseInOut']		= function (nDT) 
						return nDT
					end,
	['Elastic_EaseIn']		= function (nDT) 
    -- float newT = 0;
    -- if (nDT == 0 || nDT == 1)
    -- {
    --     newT = nDT;
    -- }
    -- else
    -- {
    --     float s = m_fPeriod / 4;
    --     nDT = nDT - 1;
    --     newT = -math.pow(2, 10 * nDT) * sinf((nDT - s) * M_PI_X_2 / m_fPeriod);
    -- }

    -- m_pInner->update(newT);
						return nDT
					end,
	['Elastic_EaseOut']		= function (nDT) 
    -- float newT = 0;
    -- if (nDT == 0 || nDT == 1)
    -- {
    --     newT = nDT;
    -- }
    -- else
    -- {
    --     float s = m_fPeriod / 4;
    --     newT = math.pow(2, -10 * nDT) * sinf((nDT - s) * M_PI_X_2 / m_fPeriod) + 1;
    -- }

    -- m_pInner->update(newT);
						return nDT
					end,
	['Elastic_EaseInOut']		= function (nDT) 
    -- float newT = 0;
    -- if (nDT == 0 || nDT == 1)
    -- {
    --     newT = nDT;
    -- }
    -- else
    -- {
    --     nDT = nDT * 2;
    --     if (! m_fPeriod)
    --     {
    --         m_fPeriod = 0.3f * 1.5f;
    --     }

    --     float s = m_fPeriod / 4;

    --     nDT = nDT - 1;
    --     if (nDT < 0)
    --     {
    --         newT = -0.5f * math.pow(2, 10 * nDT) * sinf((nDT -s) * M_PI_X_2 / m_fPeriod);
    --     }
    --     else
    --     {
    --         newT = math.pow(2, -10 * nDT) * sinf((nDT - s) * M_PI_X_2 / m_fPeriod) * 0.5f + 1;
    --     }
    -- }

    -- m_pInner->update(newT);
						return nDT
					end,
	['Black_EaseIn']			= function (nDT) 
    -- float overshoot = 1.70158f;
    -- m_pInner->update(nDT * nDT * ((overshoot + 1) * nDT - overshoot));
						return nDT
					end,	
	['Black_EaseOut']		= function (nDT) 
    -- float overshoot = 1.70158f;

    -- nDT = nDT - 1;
    -- m_pInner->update(nDT * nDT * ((overshoot + 1) * nDT + overshoot) + 1);
						return nDT
					end,	
	['Black_EaseInOut']		= function (nDT) 
    -- float overshoot = 1.70158f * 1.525f;

    -- nDT = nDT * 2;
    -- if (nDT < 1)
    -- {
    --     m_pInner->update((nDT * nDT * ((overshoot + 1) * nDT - overshoot)) / 2);
    -- }
    -- else
    -- {
    --     nDT = nDT - 2;
    --     m_pInner->update((nDT * nDT * ((overshoot + 1) * nDT + overshoot)) / 2 + 1);
    -- }
						return nDT
					end,

	['Bezier']			= function (nDT)
						return nDT
					end
}]]