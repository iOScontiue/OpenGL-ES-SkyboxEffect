//Fragment Shader

//mvp矩阵
uniform highp mat4 u_mvpMatrix;
//立方体贴图纹理采样器
uniform samplerCube u_unitCube[1];
//纹理坐标
varying lowp vec3 v_texCoord[1];

void main()
{
    //参数：指定采样的纹理；被采样的纹理坐标
    gl_FragColor = textureCube(u_unitCube[0], v_texCoord[0]);
}
