#pragma once

namespace yiq
{
    /// Converts from the RGB color space to the YIQ color space
    /// see: https://en.wikipedia.org/wiki/YIQ#From_RGB_to_YIQ
    ///
    /// @param  rgb Color in RGB color space with RGB components  ranging between 0.0 to 1.0.
    /// @return     Returns the YIQ representation.
    float3 rgb_to_yiq(float3 rgb);
    /// Converts from the YIQ color space to the RGB color space
    /// see: https://en.wikipedia.org/wiki/YIQ#From_YIQ_to_RGB
    ///
    /// @param  yiq Color in YIQ color space with y component ranging between 0.0 to 1.0, I component ranging
    ///             between -0.5957 to 0.5957, and Q component ranging from -0.5226 to 0.5226.
    /// @return     Returns the RGB representation.
    float3 yiq_to_rgb(float3 yiq);
};
