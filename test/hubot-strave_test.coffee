chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'hubot-strava', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/hubot-strava')(@robot)

  it 'registers a respond listener for Strava', ->
    expect(@robot.respond).to.have.been.calledWith(/strava$/i)

  it 'registers a respond listener for Strava friend listing', ->
    expect(@robot.respond).to.have.been.calledWith(/strava friends$/i)

  it 'registers a respond listener for Strava user search', ->
    expect(@robot.respond).to.have.been.calledWith(/strava user (.+)$/i)
