// glide_in.glsl — window-open, ported from niri's glide.kdl
// https://github.com/jgarza9788/niri-animation-collection/blob/main/animations/glide.kdl

vec4 animation(vec2 uv) {

    float p = umbriel_clamped_progress;

    // Slight up-to-down settle: 60px at start, 0 at end.
    float slide_px = (1.0 - p) * 60.0;
    float slide_uv = slide_px / max(umbriel_size.x, 1.0);

    // Very subtle scale-up into place: 0.985 -> 1.0.
    float scale = 0.985 + 0.015 * p;

    vec2 coords = uv - vec2(0.5, 0.5);
    coords /= scale;
    coords += vec2(0.5, 0.5);
    coords.y += slide_uv;

    vec4 color = umbriel_sample(coords);

    // Gentle fade-in: 0 -> 1.
    color *= p;

    return color;
}
