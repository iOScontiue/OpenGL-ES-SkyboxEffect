//
//  SceneModel.h
//  01-Car
//
//  Created by CC老师 on 2018/1/24.
//  Copyright © 2018年 CC老师. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@class SceneMesh;

//现场包围盒
typedef struct
{
    GLKVector3 min;
    GLKVector3 max;
}SceneAxisAllignedBoundingBox;

@interface SceneModel : NSObject

@property(nonatomic,strong)NSString *name;
@property(nonatomic,assign)SceneAxisAllignedBoundingBox axisAlignedBoundingBox;


- (id)initWithName:(NSString *)aName mesh:(SceneMesh *)aMesh numberOfVertices:(GLsizei)aCount;

//绘制
- (void)draw;

//顶点数据改变后，重新计算边界
- (void)updateAlignedBoundingBoxForVertices:(float *)verts count:(int)aCount;


@end
