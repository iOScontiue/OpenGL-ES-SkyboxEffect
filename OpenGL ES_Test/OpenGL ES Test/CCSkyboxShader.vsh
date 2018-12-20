//Vertex Shader

//顶点
attribute vec3 a_position;

//mvp矩阵
uniform highp mat4 u_mvpMatrix;
//纹理贴图
uniform samplerCube u_unitCube[1];
//纹理坐标
varying lowp vec3 v_texCoord[1];

void main()
{
    //获取纹理位置
    v_texCoord[0] = a_position;
    //修改顶点位置（3维变4维） = mvp矩阵 * 顶点
    gl_Position = u_mvpMatrix * vec4(a_position, 1.0);
}
