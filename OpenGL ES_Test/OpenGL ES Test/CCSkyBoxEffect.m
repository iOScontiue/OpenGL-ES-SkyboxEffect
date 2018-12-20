//
//  CCSkyBoxEffect.m
//  OpenGL ES Test
//
//  Created by 卢育彪 on 2018/12/19.
//  Copyright © 2018年 luyubiao. All rights reserved.
//

#import "CCSkyBoxEffect.h"

//立方体三角形带索引数
const static int CCSkyboxNumVertexIndices = 14;
//立方体顶点坐标数
const static int CCSkyboxNumCoords = 24;

enum
{
    CCMVPMatrix,//mvp矩阵
    CCSamplersCube,//立体贴图纹理
    CCNumUniforms//Uniform数量
};

@interface CCSkyBoxEffect()
{
    GLuint vertexBufferID;
    GLuint indexBufferID;
    GLuint program;
    GLuint vertexArrayID;
    GLint uniforms[CCNumUniforms];
}

//加载着色器
- (BOOL)loadShaders;
//编译着色器
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
//连接program(数据总线)
- (BOOL)linkProgram:(GLuint)prog;
//验证program
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation CCSkyBoxEffect

- (id)init
{
    self = [super init];
    if (self) {
        _textureCubeMap = [[GLKEffectPropertyTexture alloc] init];
        //是否使用原始纹理
        _textureCubeMap.enabled = YES;
        //采样纹理的opengl名称
        _textureCubeMap.name = 0;
        //设置纹理类型：立方体贴图
        _textureCubeMap.target = GLKTextureTargetCubeMap;
        /*纹理用于计算其输出片段颜色的模式
         GLKTextureEnvModeReplace, 输出颜色由从纹理获取的颜色.忽略输入的颜色
         GLKTextureEnvModeModulate, 输出颜色是通过将纹理颜色与输入颜色来计算所得
         GLKTextureEnvModeDecal,输出颜色是通过使用纹理的alpha组件来混合纹理颜色和输入颜色来计算的。
         */
        _textureCubeMap.envMode = GLKTextureEnvModeReplace;
        
        _transform = [[GLKEffectPropertyTransform alloc] init];
        self.center = GLKVector3Make(0, 0, 0);
        self.xSize = 1.0;
        self.ySize = 1.0;
        self.zSize = 1.0;
        
        //立方体的8个顶点
        const float vertices[CCSkyboxNumCoords] = {
            -0.5, -0.5,  0.5,
            0.5, -0.5,  0.5,
            -0.5,  0.5,  0.5,
            0.5,  0.5,  0.5,
            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,
            -0.5,  0.5, -0.5,
            0.5,  0.5, -0.5
        };
        //创建缓存对象，并返回标志符
        glGenBuffers(1, &vertexBufferID);
        //绑定缓存对象到指定缓存区：顶点
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
        //将数据拷贝到缓存对象中
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        //绘制立方体的三角形带索引
        const GLubyte indices[CCSkyboxNumVertexIndices] = {
            1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1, 2
        };
        //开辟索引缓存并复制索引数据到缓存区
        glGenBuffers(1, &indexBufferID);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    }
    return self;
}

- (void)prepareToDraw
{
    if (program == 0) {
        [self loadShaders];
    }
    
    if (program != 0) {
        glUseProgram(program);
        
        //天空盒子模型视图矩阵设置平移、缩放
        GLKMatrix4 skyboxModelView = GLKMatrix4Translate(self.transform.modelviewMatrix, self.center.x, self.center.y, self.center.z);
        skyboxModelView = GLKMatrix4Scale(skyboxModelView, self.xSize, self.ySize, self.zSize);
        
        //天空盒子模型视图矩阵与投影视图矩阵组合
        GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix, skyboxModelView);
        
        //为当前对象指定uniforms变量的值
        //MVP变换矩阵：把世界坐标系的位置转换成裁剪空间的位置
        glUniformMatrix4fv(uniforms[CCMVPMatrix], 1, 0, modelViewProjectionMatrix.m);
        //纹理采样均匀
        glUniform1i(uniforms[CCSamplersCube], 0);
        
        if (vertexArrayID == 0) {
            //OES拓展类：设置顶点属性指针
            glGenVertexArraysOES(1, &vertexArrayID);
            glBindVertexArrayOES(vertexArrayID);
            //必须启用顶点数据属性，否则顶点着色器无法读取GPU中的数据
            glEnableVertexAttribArray(GLKVertexAttribPosition);
            glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
            //将数据从CPU中传递到GPU中
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
        } else {
            //恢复所有先前编写的顶点属性
            glBindVertexArrayOES(vertexArrayID);
        }
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
        if (self.textureCubeMap.enabled) {
            glBindTexture(GL_TEXTURE_CUBE_MAP, self.textureCubeMap.name);
        } else {
            //纹理不可用，则绑定一个空的
            glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
        }
    }
}

- (void)draw
{
    glDrawElements(GL_TRIANGLE_STRIP, CCSkyboxNumVertexIndices, GL_UNSIGNED_BYTE, NULL);
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathName, *fragShaderPathName;
    
    program = glCreateProgram();
    
    vertShaderPathName = [[NSBundle mainBundle] pathForResource:@"CCSkyboxShader" ofType:@"vsh"];
    fragShaderPathName = [[NSBundle mainBundle] pathForResource:@"CCSkyboxShader" ofType:@"fsh"];
    
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathName]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathName]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    //将着色器附着到program程序上
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    //绑定属性位置，须在链接前完成
    glBindAttribLocation(program, GLKVertexAttribPosition, "a_position");
    
    //链接程序
    if (![self linkProgram:program]) {
        NSLog(@"Failed to link program:%d", program);
        
        if (vertShader != 0) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        
        if (fragShader != 0) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        
        if (program != 0) {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
    
    //获取uniform变量位置
    uniforms[CCMVPMatrix] = glGetUniformLocation(program, "u_mvpMatrix");
    uniforms[CCSamplersCube] = glGetUniformLocation(program, "u_samplersCube");
    
    if (vertShader != 0) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    
    if (fragShader != 0) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load shader");
        return NO;
    }
    
    //创建着色器
    *shader = glCreateShader(type);
    //绑定着色器
    glShaderSource(*shader, 1, &source, NULL);
    //编译完成着色器
    glCompileShader(*shader);
    
    //获取加载着色器的日志信息
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        
        free(log);
        return 0;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    //链接program
    glLinkProgram(prog);
    
    //打印链接program的日志信息
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    //获取验证program的日志信息
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    //获取验证状态
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    if (vertexArrayID != 0) {
        glDeleteVertexArraysOES(1, &vertexArrayID);
    }
    
    if (vertexBufferID != 0) {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &vertexBufferID);
    }
    
    if (indexBufferID != 0) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glDeleteBuffers(1, &indexBufferID);
    }
    
    if (program != 0) {
        glUseProgram(0);
        glDeleteProgram(program);
    }
}

@end
