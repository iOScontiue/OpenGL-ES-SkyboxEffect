//
//  TestViewController.m
//  OpenGL ES Test
//
//  Created by 卢育彪 on 2018/11/29.
//  Copyright © 2018年 luyubiao. All rights reserved.
//

#import "TestViewController.h"
#import "starship.h"
#import "CCSkyBoxEffect.h"

@interface TestViewController ()

//上下文
@property (nonatomic, strong) EAGLContext *cContext;
//基于OpenGL的简单的照明和阴影系统：包含模型视图矩阵和投影视图矩阵
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
//天空盒子效果
@property (nonatomic, strong) CCSkyBoxEffect*skyBoxEffect;
//眼睛位置：相当于脑袋位置
@property (nonatomic, assign, readwrite) GLKVector3 eyePosition;
//眼睛所看物体的位置：即物体位置
@property (nonatomic, assign) GLKVector3 lookAtPosition;
//类似脑袋指向的位置：如歪着头看物体
@property (nonatomic, assign) GLKVector3 upVector;
@property (nonatomic, assign) float angle;

//顶点/法线缓存
@property (nonatomic, assign) GLuint cPositionBuffer;
@property (nonatomic, assign) GLuint cNormalBuffer;

@property (nonatomic, strong) UISwitch *cPauseSwitch;


@end

@implementation TestViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //理解：利用GLKBaseEffect，结合天空盒子，展示效果
    [self setUpRC];
}

- (void)setUpRC
{
    //创建上下文
    self.cContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //获取GLKView并设置参数
    GLKView *view = (GLKView *)self.view;
    view.context = self.cContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.cContext];
    
    self.eyePosition = GLKVector3Make(0.0, 10.0, 10.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.0, 0.0);
    self.upVector = GLKVector3Make(0.0, 1.0, 1.0);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    //是否使用光照
    self.baseEffect.light0.enabled = GL_TRUE;
    //光照位置
    self.baseEffect.light0.position = GLKVector4Make(0.0, 0.0, 2.0, 1.0);
    //反射光颜色
    self.baseEffect.light0.specularColor = GLKVector4Make(0.25, 0.25, 0.25, 1.0);
    //漫反射光颜色
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.75, 0.75, 0.75, 1.0);
    /*计算光照策略
     GLKLightingTypePerVertex:表示在三角形的每个顶点执行照明计算，然后在三角形中插值。
     GLKLightingTypePerPixel指示对照明计算的输入在三角形内进行插值，并在每个片段上执行照明计算。
     */
    self.baseEffect.lightingType = GLKLightingTypePerPixel;
    
    //飞机旋转角度
    self.angle = 0.5;
    
    [self setMatrixs];
    
    //顶点缓存
    GLuint buffer;
    
    glGenVertexArraysOES(1, &_cPositionBuffer);
    glBindVertexArrayOES(_cPositionBuffer);
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //飞机模型数据拷贝
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipPositions), starshipPositions, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //飞机光照法线数据拷贝
    glBufferData(GL_ARRAY_BUFFER, sizeof(starshipNormals), starshipNormals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
    //开启功能：背面剔除、深度测试
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    //加载纹理图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skybox3" ofType:@"png"];
    NSError *error = nil;
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:&error];
    
    if (error) {
        NSLog(@"error------%@", error);
    }
    
    //配置天空盒子
    self.skyBoxEffect = [[CCSkyBoxEffect alloc] init];
    self.skyBoxEffect.textureCubeMap.name = textureInfo.name;
    self.skyBoxEffect.textureCubeMap.target = textureInfo.target;
    //天空盒子的长宽高
    self.skyBoxEffect.xSize = 6.0;
    self.skyBoxEffect.ySize = 6.0;
    self.skyBoxEffect.zSize = 6.0;
    
    self.cPauseSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, 30, 44, 44)];
    [self.view addSubview:self.cPauseSwitch];
    
}

- (void)setMatrixs
{
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width)/(GLfloat)(self.view.bounds.size.height);
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), aspectRatio, 0.1, 20.0);
    
    //获取世界坐标系到矩阵中
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z, self.lookAtPosition.x, self.lookAtPosition.y, self.lookAtPosition.z, self.upVector.x, self.upVector.y, self.upVector.z);
    
    //增加飞机旋转角度
    self.angle += 0.01;
    //调整脑袋位置
    self.eyePosition = GLKVector3Make(-5.0*sinf(self.angle), -5.0, -5.0*cosf(self.angle));
    //调整物体位置
    self.lookAtPosition = GLKVector3Make(0.0, 1.5+-5.0*sinf(0.3*self.angle), 0.0);
}

//场景渲染
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.5, 0.1, 0.1, 1.0);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    if (!self.cPauseSwitch.on) {
        [self setMatrixs];
    }
    
    self.skyBoxEffect.center = self.eyePosition;
    self.skyBoxEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyBoxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    
    [self.skyBoxEffect prepareToDraw];
    
    //禁止深度缓存区：即在开启深度缓存区之前应当先关闭（防止之前开启过）
    glDepthMask(false);
    [self.skyBoxEffect draw];
    glDepthMask(true);
    
    //清空缓冲区和纹理
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    
    //恢复顶点数据
    glBindVertexArrayOES(self.cPositionBuffer);
    
    //绘制飞船：材料
    for (int i = 0; i < starshipMaterials; i++) {
        
        //设置材料的漫反射颜色
        self.baseEffect.material.diffuseColor = GLKVector4Make(starshipDiffuses[i][0], starshipDiffuses[i][1], starshipDiffuses[i][2], 1.0);
        
        //设置反射光颜色
        self.baseEffect.material.specularColor = GLKVector4Make(starshipSpeculars[i][0], starshipSpeculars[i][1], starshipSpeculars[i][2], 1.0);
        
        [self.baseEffect prepareToDraw];
        
        //绘制
        glDrawArrays(GL_TRIANGLES, starshipFirsts[i], starshipCounts[i]);
    }
}

@end
