
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'The Online Feynamn Diagram Tool' });
};
