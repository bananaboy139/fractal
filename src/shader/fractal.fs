#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform vec2 screenDims;
uniform float acceptable_err;
uniform int max_trial;
uniform vec2 offset;
uniform float zoom;

out vec4 color;


const float PI = 3.1415926535;

//euler to cartesian
vec2 C_e__to__C_c(vec2 z) {
	float a = z.x * cos(z.y);
	float b = z.x * sin(z.y);
	return(vec2(a, b));
}

//absolute answers
vec2 z_1 = C_e__to__C_c(vec2(1, 0));
vec2 z_2 = C_e__to__C_c(vec2(1, 2.0*PI/3.0));
vec2 z_3 = C_e__to__C_c(vec2(1, 4.0*PI/3.0));
vec2 answers[3] = vec2[3](z_1, z_2, z_3);

float check_err(vec2 guess, vec2 ans) {
	return(length((ans - guess) / ans));
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
	vec2 z_2 = z * z;
	vec2 z_3 = z_2 * z;
	vec2 top = (2 * z_3) + 1;
	vec2 bottom = 3 * z_2;
	return(top / bottom);
}

void main() {
	vec2 z = vec2((fragTexCoord.x + offset.x/screenDims.x)/zoom, (fragTexCoord.y + offset.y/screenDims.y)/zoom);
	float trial = 0.0;
	while ((check(C_e__to__C_c(z)) > acceptable_err) && (trial < max_trial)) {
		z = optimized(z);
		trial += 1;
	}
	// trial /= 500;
	// trial *= 10;
	color = vec4(trial, trial, trial, 1);
}