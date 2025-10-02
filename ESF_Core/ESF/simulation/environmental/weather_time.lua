function ApplyEnvironmentalInfluences(weather, time)
    local mod = 1.0
    if weather == 'RAIN' or weather == 'THUNDER' then
        mod = 1.5  -- Increase accident calls
        TriggerEvent('esf:dispatch:adjustRate', '10-50', mod)
    elseif weather == 'CLEAR' and time > 12 and time < 18 then
        mod = 1.2  -- Heat wave medical
        TriggerEvent('esf:dispatch:adjustRate', '1', mod)
    elseif time > 22 or time < 6 then
        mod = 1.3  -- Night burglaries
        TriggerEvent('esf:dispatch:adjustRate', '10-14', mod)
    end
end