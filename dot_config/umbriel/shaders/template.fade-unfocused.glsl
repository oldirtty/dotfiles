const vec3 FADE_COLOR = vec3(
    float({{colors.background.default.red}}) / 255.0,
    float({{colors.background.default.green}}) / 255.0,
    float({{colors.background.default.blue}}) / 255.0
);

const float FADE_STRENGTH = 0.30;

vec4 window(vec2 uv) {
    vec4 source = umbriel_sample(uv);

    if (source.a == 0.0) {
        return source;
    }

    vec3 blended = mix(source.rgb, FADE_COLOR * source.a, FADE_STRENGTH);
    return vec4(blended, source.a);
}
