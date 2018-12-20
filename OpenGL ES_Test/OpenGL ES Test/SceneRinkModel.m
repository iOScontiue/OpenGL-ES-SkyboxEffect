//
//  SceneRinkModel.m
//  01-Car
//
//  Created by CC老师 on 2018/1/24.
//  Copyright © 2018年 CC老师. All rights reserved.
//

#import "SceneRinkModel.h"
#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "bumperRink.h"

@implementation SceneRinkModel

-(id)init
{
    SceneMesh *rinkMesh = [[SceneMesh alloc]initWithPositionCoords:bumperRinkVerts normalCoords:bumperRinkNormals texCoords0:NULL numberOfPositions:bumperRinkNumVerts indices:NULL numberOfIndices:0];
    self = [super initWithName:@"bumberRink" mesh:rinkMesh numberOfVertices:bumperRinkNumVerts];
    if (self != nil) {
        
        [self updateAlignedBoundingBoxForVertices:bumperRinkVerts count:bumperRinkNumVerts];
    }
    
    return self;
}

@end
