Blog = require('../app/Blog').Blog

describe 'blog creation', ->
  testBlog = null
  beforeEach ->
    testBlog = new Blog('test')
  it 'should have a title attribute', ->
    expect(testBlog.title).toBeDefined()
  it 'should have a title value', ->
    expect(testBlog.title).not.toBeNull()
