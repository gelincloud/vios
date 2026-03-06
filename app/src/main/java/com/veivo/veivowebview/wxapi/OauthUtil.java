package com.veivo.veivowebview.wxapi;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;


public class OauthUtil {
	public static OauthBean parseResposne(String s){
		if(s==null) return null;
		OauthBean ob = new OauthBean();
		JSONParser parser = new JSONParser();
		ByteArrayInputStream in = new ByteArrayInputStream(
				s.getBytes());
		InputStreamReader reader = new InputStreamReader(in);

		try {
			JSONObject obj = (JSONObject) parser.parse(reader);
			String access_token=(String)obj.get("access_token");
			String refresh_token=(String)obj.get("refresh_token");
			String scope = (String)obj.get("scope");
			String unionid = (String)obj.get("unionid");
			String openid=(String)obj.get("openid");
			String nickname = (String)obj.get("nickname");
			String sex = ((Long)obj.get("sex"))==null?"0": ((Long)obj.get("sex")).toString();
			String language = (String)obj.get("language");
			String headimgurl = (String)obj.get("headimgurl");
			String uid = (String)obj.get("uid");
			String avatar_hd = (String)obj.get("avatar_hd");
			String screen_name = (String)obj.get("screen_name");
			String ticket=(String)obj.get("ticket");
			ob.setAccess_token(access_token);
			ob.setRefresh_token(refresh_token);
			ob.setScope(scope);
			ob.setUnionid(unionid);
			ob.setOpenid(openid);
			ob.setNickname(nickname);
			ob.setSex(sex);
			ob.setLanguage(language);
			ob.setHeadimgurl(headimgurl);
			ob.setUid(uid);
			ob.setAvatar_hd(avatar_hd);
			ob.setScreen_name(screen_name);
			ob.setTicket(ticket);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return ob;
	}
}
