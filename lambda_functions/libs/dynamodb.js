const AWS = require('aws-sdk');

module.exports = class DynamoDB {
  constructor(config) {
    AWS.config.update(config);
    this.dynamo = new AWS.DynamoDB.DocumentClient();
  }

  async findBy(tablename, filterObject) {
    const params = {
      TableName: tablename,
      Key: filterObject
    };
    return this.dynamo.get(params).promise();
  };

  async findByAll(tablename, filterObject) {
    const keyNames = Object.keys(filterObject);
    const keyConditionExpression = keyNames.map(keyName => "#" + keyName + " = " + ":" + keyName).join(" AND ");
    const expressionAttributeNames = {}
    const expressionAttributeValues = {}
    for (const keyName of keyNames) {
      expressionAttributeNames["#" + keyName] = keyName;
      expressionAttributeValues[":" + keyName] = filterObject[keyName];
    }
    const params = {
      TableName: tablename,
      KeyConditionExpression: keyConditionExpression,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
    };
    return this.dynamo.query(params).promise();
  };

  async update(tablename, filterObject, updateObject) {
    const updateExpressionString = "set ";
    const updateExpressionAttributeValues = {}
    const keys = Object.keys(updateObject);
    for (let i = 0; i < keys.length; ++i) {
      const praceholder = ":Attr" + i.toString();
      updateExpressionString = updateExpressionString + keys[i] + " = " + praceholder;
      if (i !== keys.length - 1) {
        updateExpressionString = updateExpressionString + ", ";
      }
      updateExpressionAttributeValues[praceholder] = updateObject[keys[i]];
    }
    const params = {
      TableName: tablename,
      Key: filterObject,
      UpdateExpression: updateExpressionString,
      ExpressionAttributeValues: updateExpressionAttributeValues,
      ReturnValues: "UPDATED_NEW"
    };
    return this.dynamo.update(params).promise();
  };

  async create(tablename, putObject) {
    const params = {
      TableName: tablename,
      Item: putObject
    };
    return this.dynamo.put(params).promise();
  };

  async delete(tablename, filterObject) {
    const params = {
      TableName: tablename,
      Key: filterObject,
    };
    return this.dynamo.delete(params).promise();
  };

  async delete(tablename, filterObject) {
    const params = {
      TableName: tablename,
      Key: filterObject,
    };
    return this.dynamo.delete(params).promise();
  };

  async all(tablename){
    return this.dynamo.scan({TableName: tablename}).promise();
  }

  async where(tablename, filterObjects) {
    const requestItems = {}
    requestItems[tablename] = {
      Keys: filterObjects,
    };
    const params = {
      RequestItems: requestItems,
    }
    return this.dynamo.batchGet(params).promise();
  }
}