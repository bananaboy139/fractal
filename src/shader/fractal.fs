#version 330
in vec2 fragTexCoord;
in vec4 fragColor;

uniform vec2 screenDims;
uniform float acceptable_err;
uniform int max_trial;
uniform vec2 offset;
uniform float zoom;
uniform vec2 z_1;
uniform vec2 z_2;
uniform vec2 z_3;

out vec4 color;

vec2 C_add(vec2 z, vec2 c) {
	return(vec2(
		z.x + c.x,
		z.y + c.y
	));
}

vec2 C_mul(vec2 z, vec2 c) {
	return(vec2(
		(z.x * c.x) - (z.y * c.y),
		(z.x * c.y) + (z.y * c.x) 
	));
}

vec2 C_div(vec2 z, vec2 c) {
	return(vec2(
		((z.x * c.x + z.y * c.y) / (c.x * c.x + c.y * c.y)),
		((z.y * c.x - z.x * c.y) / (c.x * c.x + c.y * c.y))
	));
}

vec2 C_sub(vec2 z, vec2 c) {
	return(vec2(
		z.x - c.x,
		z.y - c.y
	));
}


vec2 answers[3] = vec2[3](z_1, z_2, z_3);

float check_err(vec2 guess, vec2 ans) {
	return(length(C_div(C_sub(ans, guess), ans)));
}

float check(vec2 guess) {
	float errs[3];
    for (int i = 0; i < 3; i++) {
		errs[i] = check_err(guess, answers[i]);
    }
	//really cool sort 2.0
	if (errs[1] > errs[2]) {
		errs[1] = errs[2];
	}
	if (errs[0] > errs[1]) {
		errs [0] = errs[1];
	}
	return(errs[0]);
}

vec2 optimized(vec2 z) {
	//2z^3+1 / 3*z^2
	vec2 z_2 = C_mul(z, z);
	vec2 z_3 = C_mul(z_2, z);
	vec2 top = C_add(C_add(z_3, z_3), vec2(2, 0));
	vec2 bottom = C_add(C_add(z_2, z_2), z_2);
	return(C_div(top, bottom));
}

void main() {
	vec2 z = vec2(((fragTexCoord.x + offset.x/screenDims.x)/zoom), ((fragTexCoord.y + offset.y/screenDims.y)/zoom));
	float trial = 0.0;
	while ((check(z) > acceptable_err) && (trial < max_trial)) {
		z = optimized(z);
		trial += 1;
	}
	trial /= 100;
	// trial *= 10;
	color = vec4(1, trial, trial, 1);
	
}