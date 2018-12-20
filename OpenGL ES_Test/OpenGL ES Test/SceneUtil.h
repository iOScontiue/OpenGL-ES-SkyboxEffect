//
//  SceneUtil.h
//  OpenGL ES Test
//
//  Created by 卢育彪 on 2018/12/14.
//  Copyright © 2018年 luyubiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
}SceneVertex;

typedef struct {
    SceneVertex vertices[3];
}SceneTriangle;

static const SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE = {{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

#define NUM_FACES (8)
#define NUM_NORMAL_LINE_VERTS (48)
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS+2)

SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC);

GLKVector3 SceneTriangleFaceNormal(const SceneTriangle triangle);

GLKVector3 SceneVector3UnitNormal(const GLKVector3 vectorA, const GLKVector3 vectorB);

void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[NUM_FACES]);

void SceneTrianglesUpdateVertexNormals(SceneTriangle someTriangles[NUM_FACES]);

void SceneTrianglesNormalLinesUpdate(const SceneTriangle someTriangles[NUM_FACES], GLKVector3 lightPosition, GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]);
