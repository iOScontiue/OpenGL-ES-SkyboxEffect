//
//  CCSkyBoxEffect.h
//  OpenGL ES Test
//
//  Created by 卢育彪 on 2018/12/19.
//  Copyright © 2018年 luyubiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

//GLKNamedEffect：提供基于OpenGL的着色器渲染效果的标准接口
@interface CCSkyBoxEffect : NSObject<GLKNamedEffect>

@property (nonatomic, assign) GLKVector3 center;
@property (nonatomic, assign) GLfloat xSize;
@property (nonatomic, assign) GLfloat ySize;
@property (nonatomic, assign) GLfloat zSize;

//纹理
@property (nonatomic, strong, readonly) GLKEffectPropertyTexture *textureCubeMap;
//变换
@property (nonatomic, strong, readonly) GLKEffectPropertyTransform *transform;

- (void)prepareToDraw;

- (void)draw;

@end


